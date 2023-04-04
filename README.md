# aws_status_check_autoreboot
Uma solução para identificar e reiniciar instâncias EC2 com erro de status check utilizando AWS Lambda e EventBridge

Você pode conferir o código fonte [aqui](https://github.com/chnacib/status_check_reboot_lambda): 

## Como funciona

Essa solução utiliza uma rule scheduled do EventBridge, que a cada 1 minuto, invoca uma função Lambda com python para varrer todas as instâncias EC2 de uma região, utilizando o método [describe_instances](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2.html#EC2.Client.describe_instances) e [describe_instance_status](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2.html#EC2.Client.describe_instance_status) para listar e identificar se passaram nos testes de acessibilidade e sistema. Caso algum dos testes falhe e a instância fique com status check 1/2 ou 0/2, o programa irá pausar a instância, aguardar até que o status seja "Stopped" e ligar a instância novamente. 


## Porquê não utilizar Cloudwatch alarms

Na maioria das vezes onde ocorre o erro de status check, a função de reboot não funciona. Sendo assim, seria necessário a criação de uma rotina baseada em eventos para encontrar uma determinada instância por id e por estado(dificulta a escala), aumentando assim a complexidade e encontrando limitações onde não poderia ter uma rotina de start/stop para reduzir custos, por exemplo.


## Billing AWS Lambda X Cloudwatch alarms

Outro motivo para utilizar EventBridge + AWS Lambda é que você consegue consumir utilizando o free tier, ou seja, sem pagar nada. Caso sua conta passe do free tier, o custo será de aproximadamente 2 USD/month com 43200 invocações. Enquanto no Cloudwatch alarms, a criação da métrica deve ser individual, custando em torno de 0.30 USD/month por métrica.



## Requisitos

* [awscli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Como utilizar o módulo

```
git clone https://github.com/chnacib/aws_status_check_autoreboot.git
cd aws_status_check_autoreboot/module
```

Edit ``terrafile.tf`` and replace variables in module
```
module "role" {
  source    = "../role"
  role_name = "lambda_status_check_role"
}

module "status_check_reboot_region1" {
  source        = "../"
  function_name = "status_check_reboot"
  region        = "sa-east-1"
  role_arn      = module.role.arn
  memory_size   = 128
}
```

Talvez você precise aumentar o memory_size dependendo da quantidade de instâncias EC2 em sua região, pois a lambda precisará de mais memória. para realizar a rotina


Deploy terraform module

```
terraform init
terraform apply -auto-approve
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 4.40.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.40.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_status_check_reboot"></a> [status\_check\_reboot](#module\_status\_check\_reboot) | ../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.scheduler](https://registry.terraform.io/providers/hashicorp/aws/4.40.0/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.lambda_target](https://registry.terraform.io/providers/hashicorp/aws/4.40.0/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_role.iam_for_lambda](https://registry.terraform.io/providers/hashicorp/aws/4.40.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.attach_basic_lambda](https://registry.terraform.io/providers/hashicorp/aws/4.40.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.attach_ec2_lambda](https://registry.terraform.io/providers/hashicorp/aws/4.40.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.main](https://registry.terraform.io/providers/hashicorp/aws/4.40.0/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.allow_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/4.40.0/docs/resources/lambda_permission) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Function name | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |

## Outputs

No outputs.

## Referências

https://docs.aws.amazon.com/

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/monitoring-system-instance-status-check.html

https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2.html

