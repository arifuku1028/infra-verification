"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.handler = void 0;
const client_auto_scaling_1 = require("@aws-sdk/client-auto-scaling");
const client_ec2_1 = require("@aws-sdk/client-ec2");
const promises_1 = require("node:timers/promises");
const ENI_ID = process.env.ENI_ID;
if (!ENI_ID || ENI_ID.trim() === "") {
    throw new Error("ENI_ID must be defined in environment variables");
}
const ec2 = new client_ec2_1.EC2Client({});
const autoscaling = new client_auto_scaling_1.AutoScalingClient({});
const handler = async (event) => {
    console.log("Received event:", JSON.stringify(event, null, 2));
    const { EC2InstanceId: instanceId, LifecycleHookName: lifecycleHookName, AutoScalingGroupName: asgName, } = event.detail;
    try {
        // ENIの情報を取得
        const { NetworkInterfaces } = await ec2.send(new client_ec2_1.DescribeNetworkInterfacesCommand({ NetworkInterfaceIds: [ENI_ID] }));
        const attachmentId = NetworkInterfaces?.[0]?.Attachment?.AttachmentId;
        // ENI がアタッチされていればデタッチ
        if (attachmentId) {
            console.log(`Detaching ENI ${ENI_ID} (attachmentId: ${attachmentId})`);
            await ec2.send(new client_ec2_1.DetachNetworkInterfaceCommand({
                AttachmentId: attachmentId,
                Force: true,
            }));
            // ENIが "available" になるまで待機
            await waitForEniAvailable(ENI_ID);
        }
        else {
            console.log(`ENI ${ENI_ID} is not attached, skipping detachment`);
        }
        // ENIを新インスタンスにアタッチ
        console.log(`Attaching ENI ${ENI_ID} to instance ${instanceId}`);
        await ec2.send(new client_ec2_1.AttachNetworkInterfaceCommand({
            InstanceId: instanceId,
            NetworkInterfaceId: ENI_ID,
            DeviceIndex: 1, // eth1
        }));
        // Auto Scaling にライフサイクルアクションの完了を通知
        await autoscaling.send(new client_auto_scaling_1.CompleteLifecycleActionCommand({
            AutoScalingGroupName: asgName,
            LifecycleHookName: lifecycleHookName,
            InstanceId: instanceId,
            LifecycleActionResult: "CONTINUE",
        }));
        console.log(`Lifecycle action completed for instance ${instanceId} in ASG ${asgName}`);
        return {
            statusCode: 200,
            body: JSON.stringify({
                message: "ENI attached and lifecycle continued",
            }),
        };
    }
    catch (error) {
        console.error("Failed to failover ENI:", error);
        throw error;
    }
};
exports.handler = handler;
// ENI の状態が "available" になるまでリトライ待機
const waitForEniAvailable = async (eniId, maxAttempts = 10) => {
    for (let attempt = 1; attempt <= maxAttempts; attempt++) {
        const { NetworkInterfaces } = await ec2.send(new client_ec2_1.DescribeNetworkInterfacesCommand({ NetworkInterfaceIds: [eniId] }));
        const status = NetworkInterfaces?.[0]?.Status;
        console.log(`ENI status [attempt ${attempt}]:`, status);
        if (status === "available")
            return;
        await (0, promises_1.setTimeout)(3000); // 3秒待機
    }
    throw new Error(`Timed out waiting for ENI ${eniId} to become available`);
};
