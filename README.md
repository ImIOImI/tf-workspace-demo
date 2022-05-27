# TF Workspace Demo

This is demo is intended for a developer that has little to no knowledge of Terraform workspaces or how to use them, but
wants to keep their code as [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) as possible.

## What is a workspace?

The closest analogy I can make is that a workspace functionally is like a stateful instance of a class. It can be called 
multiple times with different inputs and outputs, but ultimately it executes using the same code. The terraform code 
acts like a template to create multiple objects that contain resources each of which can be created using configs unique
to the workspace that contains them.

## Getting started

I recommend cloning this repo locally and installing [tfenv](https://github.com/tfutils/tfenv) (tfenv is a terraform 
version manager that's killer useful). However, this demo should be compatible with Terraform 0.12+. I'm keeping 
everything simple and constraining it to variables and outputs, no resources will be created, so no AWS/AZ/GCP accounts 
are necessary. Each of the examples is meant to gradually build on what we learned with the last example, so I don't 
just dump all the complication of the final version on the reader all at once. 

## Example 1

First, let's get the basics out of the way. Navigate to `example1` and look at the locals.tf file. We want to define a
guid for our organization that should remain the same across all our future environments so we do that in a fairly 
normal way like:

```terraform
organisation-id = "06288276-e890-4c3d-bfe7-bdb96cfd304b"
```

However, we're also grabbing the name of the workspace like this:

```terraform
  workspace = terraform.workspace
```

You can see what happens when you execute the following:

#### cli input
```shell
❯ terraform init
❯ terraform apply
```

#### cli output
```shell
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

organization-id = 06288276-e890-4c3d-bfe7-bdb96cfd304b
workspace = default
```

Here, you can see the organization output is exactly what you would expect, but the output for `terraform.workspace` is 
`default`. This is because whether you know it or not, when you init a project in terraform, you're in the `default` 
workspace. 

Let's change it up a bit and switch workspaces and apply by doing the following:

#### cli input
```shell
❯ terraform workspace new dev
```

#### cli output
```shell
Created and switched to workspace "dev"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
```

Now let's repeat the terraform apply

```shell
❯ terraform apply

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

organization-id = 06288276-e890-4c3d-bfe7-bdb96cfd304b
workspace = dev
```

Note that the workspace has changed, but the organization-id remains the same. Now we have a variable that we can use to 
help us associate values to a workspace

Some of the commands that we'll be using that might be unfamiliar to you if you haven't worked with workspaces before 
are the following:
```terraform
#add a new workspace
terraform workspace new <workspace name>

#show a list of all the workspaces that exist
terraform workspace list

#select a workspace to work with
terraform workspace select <workspace name>
```

## Example 2

Next navigate to `example-2`. Here in the locals.tf file we have an example of how to define an organization wide 
network and we have it divided up into smaller subnets in each of the contexts. The map `contexts` enumerates all the 
possible workspaces  

1) First init the environment by running the following:
```shell
terraform init
terraform workspace new dev
terraform workspace new infra
terraform workspace new stage
terraform workspace new prod
```
2) Let's look at what we just did by running `terraform workspace list` the output should look like this (obviously, 
the * denoted the current workspace that we're using)
```shell
❯ terraform workspace list
  default
  dev
  infra
* prod
  stage
```
3) Now we can go through the workspace and check on the results like:
```shell
#dev
❯ terraform workspace select dev
Switched to workspace "dev".
❯ terraform apply

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

network = 10.0.0.0/8
organization-id = 06288276-e890-4c3d-bfe7-bdb96cfd304b
subnet = 10.16.0.0/12
workspace = dev
```
```shell
#infra
❯ terraform workspace select infra
Switched to workspace "infra".
❯ terraform apply

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

network = 10.0.0.0/8
organization-id = 06288276-e890-4c3d-bfe7-bdb96cfd304b
subnet = 10.32.0.0/12
workspace = infra
```
etc..

So, now you know how to set up workspaces to be able to set up dynamically populated variables that change based on 
which workspace you're in... but typing every possible configuration in every context isn't very DRY. Let's change 
that.

## Example 3

Now, we're getting to how we can save keystrokes in configuring the environments. Let's envision that we want to
provision DR environments. To do this, we need to add an extra context in stage (so we can test failover) and prod. Our 
goal is to keep everything as DRY as possible. So, we set up all the default values in the default context, then do a 
merge to make sure that any other environments inherit those defaults and have a chance to override them.

So, for example, the default map looks like this
```terraform
default = {
  environment = "dev"
  region      = "eastus" #this is overridden in west contexts
  country     = "us" #this is set just once and isn't overridden anywhere else
  subnet      = cidrsubnet(local.network,  16, 0)
}
```
The dev map looks like this
```terraform
dev = {
  subnet = cidrsubnet(local.network,  16, 1)
}
```
The code following code merges the two maps
```terraform
ctxtvar  = contains(keys(local.contexts), local.workspace) ? local.workspace : "default"
ctxtvars = merge(local.contexts["default"], local.contexts[local.ctxtvar])
```
---
**NOTE**
Terraform doesn't have a concept of public/private, so one code style choice I make is to remove vowels from things I 
consider private. This makes them a little harder to read or remember and hints that it might be anti-pattern to call 
them directly. This is by no means a common convention, just a personal one that I use. 
---
The output of the merge will look like this
```terraform
dev = {
  environment = "dev"
  region      = "eastus"
  country     = "us"
  subnet      = cidrsubnet(local.network,  16, 1)
}
```
Test this out by initializing the environments and running applies
```shell
terraform init
terraform workspace new dev
terraform workspace new infra 
terraform workspace new stage-east
terraform workspace new stage-west
terraform workspace new prod-east
terraform workspace new prod-west
```
All the values from the merged values can be accessed like this:
```terraform
  subnet      = local.ctxtvars["subnet"]
  region      = local.ctxtvars["region"]
  country     = local.ctxtvars["country"]
  environment = local.ctxtvars["environment"]
```
Now one question that you might have right now is why not just access the map directly from your code like:
```terraform
resource "random_pet" "server" {
  keepers = {
    region = local.ctxtvars["subnet"]
  }
}
```
The above code certainly saves a couple keystrokes in the locals, but imo (and note that this is my opinion, not any 
kind of Terraform convention) I think the map should be treated as private. It would take an unnecesary understanding of 
the data structure to reach into the map and pull out values. Instead, I write what are analogous to getters to access 
the data. Furthermore, my approach has the added benefit of not breaking code completion in an IDE. Therefore, I believe 
the code snippet above is anti-pattern and the following code would be better:
```terraform
resource "random_pet" "server" {
  keepers = {
    region = local.subnet
  }
}
```
## Example 4

Let's imagine that we have a hub and spoke network with the `infra` environment being the hub. We might need to grab the 
subnet cidr for the infra context so we can build networking rules, routes, and firewall rules for that subnet. Of 
course, we don't want to write the infra subnet in every context, so instead we're going to continue to build out the 
map of all contexts. This is similar to what we did in example 3, but this time we're iterating over the map of all the 
contexts

```terraform
  //merge all the defaults with their contexts
  merged-contexts = {
  for context, v in local.contexts : context =>
  merge(
    local.contexts["default"],
    v,
  )
  }
```

Now, `merged-contexts` contains all the merged values for every context and you have the first oppurtunity to share info 
and settings between contexts. 

Another common use case that simpler configuration management approaches don't handle well is managing values that are 
strongly coupled. For example, what if I want to specify the max number of nodes for a kubernetes cluster in 
dev/stage/prod? What if I want to add timezone information on a per region basis. I could easily just go into each 
context and type out the timezone/max-nodes/etc... but this IS a tutorial on how to DRY up your configs, after all and 
if you've gotten this far, you probably thing that such an approach feels wrong.

So the way we're going to solve this is to create more files, each with local variables that depend on environment or 
region. For example for the dev environment we have the following:

```terraform
dev = {
  k8s-max-nodes = 10
  environment-long = "development"
  environment-short = "dev"
}
```

For the east region we have the following:
```terraform
east = {
  timezone = "PST"
  time-offset = "-8"
}
```

Now, we need to tie everything together and merge all the region and environment maps into the context map
```terraform
  all-contexts = {
  for context, values in local.merged-contexts : context =>
  merge(
    values,
    local.environments[values.environment],
    local.regions[values.region],
  )
  }
```

## Example 5

All the above is great and all, but what if we need to use this configuration with more than one project? Also, 
wouldn't it be cool if we could just abstract all of it away? Let's move it into a module and get it out of our project 
code

The contexts map that was in locals.tf has been moved to `example-5/modules/contexts.tf` and the loops and merges were
moved into `example-5/modules/main.tf`. The workspace is now being set via the variable declaration in variables.tf.

Now locals.tf just looks like this:
```terraform
locals {
  workspace = terraform.workspace

  organisation-id = module.global.organisation-id
  network         = module.global.network
  subnet          = module.global.subnet
  region          = module.global.region
  country         = module.global.country
  environment     = module.global.environment
  timezone        = module.global.timezone
  time-offset     = module.global.time-offset
  k8s-max-nodes   = module.global.k8s-max-nodes
  hub-subnet      = module.global.hub-subnet
  env-timezone    = module.global.env-timezone
}

module "global" {
  source = "./modules/global"
  context = local.workspace
}
```

Before ending the tutorial, we're going to add one more thing. We need to be able to calculate values based on settings 
that might be set in environment or regions. To do this, we're going to loop through the contexts one final time like 
this:

```terraform
  all = {
    for context, v in local.all-contexts : context =>
      merge(
        v,
        {env-timezone = "${v.environment-short}-${v.country}-${v.timezone}"}
      )
  }
```

This example is a bit silly, but it demonstrates how we can generate calculated strings based on cross domain 
configuration. 

## Conclusion

This approach demonstrates an effective way to keep your Terraform code DRY. 

## Apendix

If you like the above approach, you can stop reading here. I'm adding the following to answer what I think are common 
responses to this approach.

### Why I Don't Use .tfvars Files

The primary argument I have against using .tfvars for this kind of work is that if you're concerned about the verbosity 
of the code already contained in this tutorial, then you should be incredibly concerned about the verbosity using 
tfvars. The most straight forward approach to solving the same issue is to add a .tfvar file for every workspace and 
pass it in to the terraform apply step at planning or apply time. Therefore, for each value that you need to output in 
the global module you need to have an input via a tfvars file. Furthermore, you also have to add a variable to consume 
the tfvar input. Let's run through the implications of this. 

For demonstration purposes, here is the output of the `all-contexts` map in the global 
module:

```terraform
all-contexts = {
  "default" = {
    "country" = "us"
    "environment" = "dev"
    "environment-long" = "development"
    "environment-short" = "dev"
    "k8s-max-nodes" = 10
    "region" = "east"
    "subnet" = "10.0.0.0/24"
    "time-offset" = "-8"
    "timezone" = "EST"
  }
  "dev" = {
    "country" = "us"
    "environment" = "dev"
    "environment-long" = "development"
    "environment-short" = "dev"
    "k8s-max-nodes" = 10
    "region" = "east"
    "subnet" = "10.0.1.0/24"
    "time-offset" = "-8"
    "timezone" = "EST"
  }
  "infra" = {
    "country" = "us"
    "environment" = "dev"
    "environment-long" = "development"
    "environment-short" = "dev"
    "k8s-max-nodes" = 10
    "region" = "east"
    "subnet" = "10.0.2.0/24"
    "time-offset" = "-8"
    "timezone" = "EST"
  }
  "prod-east" = {
    "country" = "us"
    "environment" = "prod"
    "environment-long" = "production"
    "environment-short" = "prd"
    "k8s-max-nodes" = 30
    "region" = "east"
    "subnet" = "10.0.5.0/24"
    "time-offset" = "-8"
    "timezone" = "EST"
  }
  "prod-west" = {
    "country" = "us"
    "environment" = "prod"
    "environment-long" = "production"
    "environment-short" = "prd"
    "k8s-max-nodes" = 30
    "region" = "west"
    "subnet" = "10.0.6.0/24"
    "time-offset" = "-5"
    "timezone" = "PST"
  }
  "stage-east" = {
    "country" = "us"
    "environment" = "stage"
    "environment-long" = "staging"
    "environment-short" = "stg"
    "k8s-max-nodes" = 30
    "region" = "east"
    "subnet" = "10.0.3.0/24"
    "time-offset" = "-8"
    "timezone" = "EST"
  }
  "stage-west" = {
    "country" = "us"
    "environment" = "stage"
    "environment-long" = "staging"
    "environment-short" = "stg"
    "k8s-max-nodes" = 30
    "region" = "west"
    "subnet" = "10.0.4.0/24"
    "time-offset" = "-5"
    "timezone" = "PST"
  }
}
```

For the 6 contexts we have here we have 9 possible outputs which means we require 54 .tfvar entries like this:
```terraform
# dev.tfvars  values
country = "us"
environment = "dev"
environment-long = "development"
environment-short = "dev"
k8s-max-nodes = 10
region = "east"
subnet = "10.0.0.0/24"
time-offset = "-8"
timezone = "EST"
#infra.tfvars values
country = "us"
environment = "dev"
environment-long = "development"
environment-short = "dev"
k8s-max-nodes = 10
region = "east"
subnet = "10.0.2.0/24"
time-offset = "-8"
timezone = "EST"
#... etc
```
After that, we need to add variables for each of the above lines like: 
```terraform
variable "country" {
  type = string
}
variable "environment" {
  type = string
}
#etc...
```
Then when we apply the terraform code, we do something like:
```shell
terraform apply -var-file="dev.tfvars"
```
My issue here is that the maintainability of this over time becomes difficult
```
Let W = workspaces
Let V = variables
Let I = number of tfvars inputs

I = WV
```

This means any new addition expands the necessary code quadratically. I can tell you from experience, that this becomes 
harder and harder to maintain overtime. 

We can cut this down by using variables with defaults and override specific values in specific tfvars files.  

It is true that you can take a similar approach to what I did here and use variables with defaults and tfvars to substitute values into the 
contexts/environments/region maps like:

```terraform
variable "country" {
  default = "us"
  type = string
}
variable "environment" {
  default = "dev"
  type = string
}
variable "region" {
  default = "east"
  type = string
}
locals {
  country     = var.country
  environment = var.environment
  region      = var.region
  #etc...
}
```

This isn't terrible, but remember how we had other values that were strongly coupled to environment and region? Now, 
we're forced to define them in every tfvars file and fall victim to the `I = WV` quadratic expansion of definitions in 
the tfvars files, again or we could do the following:

```terraform
variable "country" {
  default = "us"
  type = string
}
variable "environment" {
  default = "dev"
  type = string
}
variable "region" {
  default = "east"
  type = string
}
locals {
  country     = var.country
  environment = var.environment
  region      = var.region
  #etc...
  
  regions = {
    east = {
      timezone = "EST"
      time-offset = "-8"
    }
    west = {
      timezone = "PST"
      time-offset = "-5"
    }
  }
  
  timezone = locals.regions[local.region]["timezone"]
  timezone = locals.regions[local.region]["time-offset"]
}
```
That's a great approach, but that kinda leads us full circle again, doesn't it? Why not define the rest of the variables 
that way at this point? Furthermore, I contend that it's much easier to understand the general configuration of all your 
infrastructure in my original approach. It deliberately has all the contexts/regions/environments defined next to each 
other and it's easier to understand which value flows into which context. Ultimately, in the long run I don't think the
tfvars approach saves any complexity and suffers from a deficit in readability. 
