import {
  AutoScalingClient,
  CompleteLifecycleActionCommand,
} from "@aws-sdk/client-auto-scaling"
import {
  AttachNetworkInterfaceCommand,
  DescribeNetworkInterfacesCommand,
  DetachNetworkInterfaceCommand,
  EC2Client,
} from "@aws-sdk/client-ec2"
import { EventBridgeEvent } from "aws-lambda"
import { setTimeout } from "node:timers/promises"

const ENI_ID = process.env.ENI_ID
if (!ENI_ID || ENI_ID.trim() === "") {
  throw new Error("ENI_ID must be defined in environment variables")
}

const ec2 = new EC2Client({})
const autoscaling = new AutoScalingClient({})

interface ScaleOutLifecycleEventDetail {
  LifecycleActionToken: string
  AutoScalingGroupName: string
  LifecycleHookName: string
  EC2InstanceId: string
  LifecycleTransition: string
  NotificationMetadata: string
  Origin: string
  Destination: string
}

export const handler = async (
  event: EventBridgeEvent<
    "EC2 Instance-launch Lifecycle Action",
    ScaleOutLifecycleEventDetail
  >,
) => {
  console.log("Received event:", JSON.stringify(event, null, 2))

  const {
    EC2InstanceId: instanceId,
    LifecycleHookName: lifecycleHookName,
    AutoScalingGroupName: asgName,
  } = event.detail

  try {
    // ENIの情報を取得
    const { NetworkInterfaces } = await ec2.send(
      new DescribeNetworkInterfacesCommand({ NetworkInterfaceIds: [ENI_ID] }),
    )
    const attachmentId = NetworkInterfaces?.[0]?.Attachment?.AttachmentId

    // ENI がアタッチされていればデタッチ
    if (attachmentId) {
      console.log(`Detaching ENI ${ENI_ID} (attachmentId: ${attachmentId})`)
      await ec2.send(
        new DetachNetworkInterfaceCommand({
          AttachmentId: attachmentId,
          Force: true,
        }),
      )

      // ENIが "available" になるまで待機
      await waitForEniAvailable(ENI_ID)
    } else {
      console.log(`ENI ${ENI_ID} is not attached, skipping detachment`)
    }

    // ENIを新インスタンスにアタッチ
    console.log(`Attaching ENI ${ENI_ID} to instance ${instanceId}`)
    await ec2.send(
      new AttachNetworkInterfaceCommand({
        InstanceId: instanceId,
        NetworkInterfaceId: ENI_ID,
        DeviceIndex: 1, // eth1
      }),
    )

    // Auto Scaling にライフサイクルアクションの完了を通知
    await autoscaling.send(
      new CompleteLifecycleActionCommand({
        AutoScalingGroupName: asgName,
        LifecycleHookName: lifecycleHookName,
        InstanceId: instanceId,
        LifecycleActionResult: "CONTINUE",
      }),
    )

    console.log(
      `Lifecycle action completed for instance ${instanceId} in ASG ${asgName}`,
    )

    return {
      statusCode: 200,
      body: JSON.stringify({
        message: "ENI attached and lifecycle continued",
      }),
    }
  } catch (error) {
    console.error("Failed to failover ENI:", error)
    throw error
  }
}

// ENI の状態が "available" になるまでリトライ待機
const waitForEniAvailable = async (eniId: string, maxAttempts = 10) => {
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    const { NetworkInterfaces } = await ec2.send(
      new DescribeNetworkInterfacesCommand({ NetworkInterfaceIds: [eniId] }),
    )

    const status = NetworkInterfaces?.[0]?.Status
    console.log(`ENI status [attempt ${attempt}]:`, status)

    if (status === "available") return
    await setTimeout(3000) // 3秒待機
  }

  throw new Error(`Timed out waiting for ENI ${eniId} to become available`)
}
