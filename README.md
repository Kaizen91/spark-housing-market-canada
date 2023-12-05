# spark-housing-market-canada
An ETL project using canadian housing data to demonstrate knowledge of Spark, Terraform, and GCP (Dataproc, Cloud Storage, BigQuery)

Requirements:

Terraform installed [link]
GCP trial account [link]
NOTE:  you need a credit card to create an account, but you will not be billed unless you opt in to upgrade your account.  The free account comes with $300 worth of credits as of the writing of this document


Preliminary set up:
    create a project
    [image]
    enable Compute Engine API
    enable Cloud Dataproc API
    enable Identity and Access Management (IAM) API
    enable Cloud Resource Manager API
    create a service account for terraform
        1. search "service accounts" in the search bar and open this link
        2. click create service account
        3. give the service account the Basic > Editor Role
        4. create a key and download it into the working directory of this project.  Your setup should look something like this: [image]
    

Steps to Run:

1. Update the terraform.tfvars file with your gcp project id (you created above) and the key file you downloaded when you created your service account (again done above)
2. Run terraform fmt to check for formating errors
3. Run terraform validate to make sure the main.tf file is valid
4. Run terraform apply to create the infrastructure and create the Dataproc job
5. That's it!  if everything ran successfully you should have 5 tables created in BigQuery.  Each table has transformed the source data in a different way based on the transform.py script.

Shutdown:

Once you're ready to shut everything down just run terraform destroy.  This will destroy all the infrastructure so you do not spend any more of your free credits.
