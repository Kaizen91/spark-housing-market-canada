# spark-housing-market-canada
An ETL project using canadian housing data to demonstrate knowledge of Spark, Terraform, and GCP (Dataproc, Cloud Storage, BigQuery)

Requirements:

Terraform installed [link](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli)
GCP trial account [link](https://cloud.google.com/free)
NOTE:  you need a credit card to create an account, but you will not be billed unless you opt in to upgrade your account.  The free account comes with $300 worth of credits as of the writing of this document


Preliminary set up:

    create a project

![create a project](https://github.com/Kaizen91/spark-housing-market-canada/blob/main/images/GCP-create-new-project.png)

    Enable the following APIs
    * Compute Engine API
    * Cloud Dataproc API
    * Identity and Access Management (IAM) API
    * Cloud Resource Manager API

    create a service account for terraform

1. search "service accounts" in the search bar and open the first option.  You should see a screen that corresponds to the below screenshots
2. click create service account

![create service account](https://github.com/Kaizen91/spark-housing-market-canada/blob/main/images/GCP-create-service-account.png)

3. give the service account the Basic > Editor Role
![service account editor role](https://github.com/Kaizen91/spark-housing-market-canada/blob/main/images/GCP-service-account-editor.png)
4. create a key and download it into the working directory of this project.
![create service account key](https://github.com/Kaizen91/spark-housing-market-canada/blob/main/images/GCP-service-account-key.png)

Steps to Run:

1. Update the terraform.tfvars file with your gcp project id (you created above) and the key file you downloaded when you created your service account (again done above)
2. Run terraform fmt to check for formating errors
3. Run terraform validate to make sure the main.tf file is valid
4. Run terraform apply to create the infrastructure and create the Dataproc job
5. That's it!  if everything ran successfully you should have 5 tables created in BigQuery.  Each table has transformed the source data in a different way based on the transform.py script.

Shutdown:

Once you're ready to shut everything down just run terraform destroy.  This will destroy all the infrastructure so you do not spend any more of your free credits.
