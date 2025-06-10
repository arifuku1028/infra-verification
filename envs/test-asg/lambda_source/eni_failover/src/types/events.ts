export interface ScaleOutLifecycleEventDetail {
  LifecycleActionToken: string
  AutoScalingGroupName: string
  LifecycleHookName: string
  EC2InstanceId: string
  LifecycleTransition: string
  NotificationMetadata: string
  Origin: string
  Destination: string
}
