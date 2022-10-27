# tf-modules
Terraform Modules to be used by d-influencers

## How to use
In your code, use this module in the source of the module definition, like:

```
module "d-influencer-repos" {

  source = "git::https://github.com/iSociall/tf-modules//modules/ecr?ref=v1.1.0"

  ...
  
}
```

Please, pay atention to syntax of the module and put the correct module version

`git::https://github.com/iSociall/tf-modules//modules/` ***MODULE_NAME*** `?ref=` ***TAG_VERSION***
