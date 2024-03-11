# Create an AWS EKS Fargate Cluster Integrated with an ALB and ACM Certificate(TLS) Using Terraform Infrastructure as Code (IaC)

Learn how to create a Kubernetes cluster on Amazon EKS using Terraform Infrastructure as Code. 

This tutorial focuses on deploying a Fargate-based cluster, integrating an Application Load Balancer, and securing it with an Amazon ACM Certificate for TLS. 

Watch the complete tutorial on the [BloomLessons YouTube Channel](https://www.youtube.com/channel/UCQs-Wfxvh3fR14tvfpBSj9Q). Jump straight to [the playlist here](https://www.youtube.com/playlist?list=PLM0KCx6YmWqILL-b7MdDx6rfKUpYe9KjU). Don't forget to subscribe for more helpful content and to show your support!

## The `iam-policy/` folder

Building the tutorial around the principles of least access, you'll find the content of the custom inline policy document that can be linked to the user created in the tutorial's preparation phase, following the provided guidance. Ensure to customize the AWS Account ID and Region details in this policy before using it.

Apart from the inline policy, the user will also need several AWS managed policies.:
1. `AmazonVPCFullAccess`
2. `AmazonRoute53FullAccess`
3. `AWSCertificateManagerFullAccess`
4. `ElasticLoadBalancingReadOnly`

Depending on your specific use case, the mentioned managed policies could be overly broad or too permissive for your configuration. You're welcome to transfer necessary permissions into the custom inline policy, where you can restrict them as needed.

## The `examples/` folder
Within this directory, you'll find three examples utilized in the tutorial, each is written using Kubernetes YAML manifests. 

Prior to implementing the resources outlined in the tutorial, be sure to make necessary modifications as specified below:

1. Change the Ingress annotation to use your own ACM certificate arn: 
   ``` yaml
   alb.ingress.kubernetes.io/certificate-arn: "arn:aws:acm:YOURAWSREGION:YOURAWSACCOUNTID:certificate/YOURACMCERTIFICATEID"
   ```
2. Each ingress rules host must use your own domain under:
   ```yaml
   rules:
    - host: bloom.kubernetes.YOURDOMAIN.COM
   ````

## The `lb-controller/` folder
For the `values.yaml` in this folder ensure you update each necessary key to use your AWS account information:
```yaml
serviceAccount:
  ...
  annotations: { eks.amazonaws.com/role-arn: "arn:aws:iam::YOURAWSACCOUNTID:role/bloomlessons-lb-controller-role" }
  ...

createIngressClassResource: true

region: "YOURAWSREGION"

vpcId: "vpc-YOURVPCID"
```

## Reference Links for the tutorial:
Below are links provided for further details on the subject:
1. [Creating a public hosted zone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingHostedZone.html)
2. [Requesting a public certificate](https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html)
3. [Getting started with AWS Fargate using Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/fargate-getting-started.html)
4. [AWS Fargate profile](https://docs.aws.amazon.com/eks/latest/userguide/fargate-profile.html)
5. [EKS Deploy a sample application](https://docs.aws.amazon.com/eks/latest/userguide/sample-deployment.html)
6. [Application load balancing on Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html)
7. [AWS LoadBalancer Controller Ingree Annotations](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.5/guide/ingress/annotations/)
8. [Setting up OID Identity Provider for Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html)