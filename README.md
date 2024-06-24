# ETL-pipeline-for-random-users

In this project, I built an ETL pipeline that retrieves data for randomly generated users by calling the API at 'https://randomuser.me/api/'. After processing the data, it is saved into a DynamoDB table. I utilized the Infrastructure as Code framework, Terraform, to create the necessary infrastructure on AWS.

#### Prerequisites: 
1. Having an AWS user with necessary permissions configured locally. Use **aws configure** command to configure AWS user profile locally and provide the Access key ID and Secret access key when asked. 

2. Docker should be installed locally.

This project consists of following three modules:

#### Module 1: Fetch random users data and load it to S3 bucket
 In this module, I fetched randomly generated user data by calling the API at 'https://randomuser.me/api/' and loaded it into an S3 bucket on AWS. This task is scheduled to run every hour using Airflow, which I set up to run in a Docker container.

 Following steps are followed to set up this module:

 **1. Create some required directories and provide necessary permissions.**

        mkdir dags logs script user_data
        chmod -R 777 dags logs script user_data

**2. Include the `entrypoint.sh` file in the script directory**

**3. Create a virtual Python environment and activate it**

    python3 -m venv myenv
    source myenv/bin/activate

**4. install all the necessary libraries which is required for writing the Dag**

    pip install requests
    pip install boto3
    pip install apache-airflow==2.9.1

**5. Create the requirement.txt file from the Python environment which is required to be installed in Airflow docker container.**

    pip freeze > requirements.txt

**6. Write docker-compose.yml file and include necessary components of Airflow i.e. webserver, scheduler, postgres and mount necessary volumes on scheduler and webserver.**

    docker-compose up

**7. Include the Python script into `dags' folder.**

**8. Specify AWS access credentials into Airflow connection through web interface.**


#### Module 2: Incremental load of user data into another S3 location 
In this module, user data files are loaded from the landing bucket to the cleaned bucket incrementally. I utilized an AWS Lambda function for this task, developing the code locally, packaging all the necessary libraries and code into a zip file, and deploying the zip file to AWS Lambda.

Following steps are followed to set up this module:

**1. Create a virtual Python environment and activate it**

    python3 -m venv myenv
    source myenv/bin/activate

**2. Install necessary libraries**

    pip install requests
    pip install boto3

**3. Develop the code for incremental load locally and test it.**

**4. Install the libraries used in this module that are not available in the AWS environment by default into a separate folder. Include the Python scripts in this folder as well, and then create a zip file.**

    mkdir libs_to_deploy
    pip install requests -t libs_to_deploy
    cd libs_to_deploy
    zip -r ../inc_load_random_users.zip .
    cd ..
    zip -g inc_load_random_users.zip lambda_function.py util.py

**5. Deploy the zip file on AWS lanbda.**

#### Module 3: ETL Glue script to save user data into DynamoDB
This module involves writing a Glue job that reads data from the S3 cleaned bucket and loads it into a DynamoDB table. I developed the Glue job locally by setting up AWS Glue in a Docker container to avoid AWS charges during development and testing. Finally, I deployed the Glue job on AWS.

The following steps are followed for this module:

**1. Set up AWS glue 4.0 in docker container to develop and test the ETL glue script locally.** 

    docker pull amazon/aws-glue-libs:glue_libs_4.0.0_image_01

**2. Run the following command to run AWS glue in docker container.**

    docker run -it 
    -v ./jupyter_workspace/:/home/glue_user/workspace/jupyter_workspace/ 
    -e DISABLE_SSL=true 
    --rm -p 4040:4040 
    -p 18080:18080 
    -p 8998:8998 
    -p 8888:8888 
	--name glue_jupyter_lab amazon/aws-glue-libs:glue_libs_4.0.0_image_01 /home/glue_user/jupyter/jupyter_start.sh

**3. Develop the ETL Glue script using jupyter lab accessible at localhost:8888**

**4. To test the script on AWS environment, add the aws profile name which is set up locally, to the previous command.**

    docker run -it -v C:\Users\PrashantRay\.aws:/home/glue_user/.aws 
    -v ./jupyter_workspace/:/home/glue_user/workspace/jupyter_workspace/ 
    -e AWS_PROFILE=awsdemo 
    -e DISABLE_SSL=true 
    --rm -p 4040:4040 
    -p 18080:18080 
    -p 8998:8998 
    -p 8888:8888 
	--name glue_jupyter_lab amazon/aws-glue-libs:glue_libs_4.0.0_image_01 /home/glue_user/jupyter/jupyter_start.sh

**5. Finally, deploy the Glue ETL script in the AWS environment.**

#### Module: iac_terraform

This module contains the infrastructure code necessary for the project, utilizing Terraform to set up the required infrastructure in the AWS environment.