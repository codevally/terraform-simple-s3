<h2> Open Policy Agent policies to evaluate terraform code for compliance and security policies </h2>

These policies will be evaluated during CICD pipeline and it is mandatory to include the policies for all the pipelines. 

<p>

Example code to check if all the s3 buckets have acl property set to private ( unless it’s a website bucket).

```
# S3 acl property , bucket ACL can't be private unless its is a website hosting bucket.
s3_acl_change[resource_type] = num {
    some resource_type
    resource_types[resource_type]
    all := resources[resource_type]
    modifies := [res |  res:= all[_]; res.change.after.acl == "public"; res.change.after.website != null]
    num := count(modifies)
}
```

OPA commands


```
1. terraform init
2. terraform plan --out tfplan.binary
3. terraform show -json tfplan.binary > tfplan.json
4. opa eval --format pretty --data s3-validate.rego --input tfplan.json "data.terraform.analysis.score"
5. opa eval --format pretty --data s3-validate.rego --input tfplan.json "data.terraform.analysis.authz"
6. opa eval -f pretty --explain=notes  --data s3-validate.rego --input tfplan.json "authorized = data.terraform.analysis.authz; violations = data.terraform.analysis.violation"
```

"data.terraform.analysis.authz" returns true / false indicating success of failure of evaluation of policies

"data.terraform.analysis.score" returns either zero or count of score indicating weight of evaluation of policies - this weight (score) can be used to set a threshold.
for example : if score > 20 then fail the pipeline
where 20 is you minimum allowed threshold value.

data.terraform.analysis.violation will output the error messages, refer to this git issue log to understand more about violation
https://github.com/open-policy-agent/opa/issues/2104


Missing required tags and , creating bucket in invalid region will output following errors 

```
command : 
opa eval -f pretty --explain=notes  --data s3-validate.rego --input tfplan.json "authorized = data.terraform.analysis.authz; violations = data.terraform.analysis.violation"

+------------+--------------------------------+
| authorized |           violations           |
+------------+--------------------------------+
| false      | ["missing required             |
|            | tags","bucket region shoule be |
|            | in eu-cantral-1 "]             |
+------------+--------------------------------+
```
