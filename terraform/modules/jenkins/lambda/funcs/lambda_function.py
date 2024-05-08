import requests
import os
from time import sleep

JENKINS_URL= os.environ['JENKINS_URL']
API_TOKEN = os.environ['API_TOKEN']

def lambda_handler(event, context):
    try:
        url = "http://{}:8080/job/capstone-deployment/build?token={}".format(JENKINS_URL, API_TOKEN)
        response = requests.get(url)

        if response.status_code != 201:
          print(response.status_code)
    except Exception as err:
      print(err.args[0])
