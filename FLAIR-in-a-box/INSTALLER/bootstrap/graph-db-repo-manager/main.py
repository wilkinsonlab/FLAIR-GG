import requests
import sys
import chevron
import time
import os
from requests.auth import HTTPBasicAuth

GRAPHDB_ADMIN_USER = os.environ['GRAPH_DB_ADMIN_USERNAME']
GRAPHDB_ADMIN_PASSWORD = os.environ['GRAPH_DB_ADMIN_PASSWORD']
FDP_PREFIX = os.environ['FDP_PREFIX']
graphdb_url = os.environ['GRAPH_DB_URL']


def check_triple_store_status(graphdb_url):
    url = graphdb_url + "/rest/repositories"
    try:
        response = requests.request("GET", url,auth = HTTPBasicAuth(GRAPHDB_ADMIN_USER,GRAPHDB_ADMIN_PASSWORD))
        print(response.headers)
        if response.status_code == 200:
            return True
    except:
        return False


def check_repository(graphdb_url, repo_id):

    url = graphdb_url + "/rest/repositories/" + repo_id
    does_repo_exists = False
    headers = {'Accept': "text/turtle"}
    print("Checking repository")

    response = requests.request("GET", url, headers=headers, auth = HTTPBasicAuth(GRAPHDB_ADMIN_USER,GRAPHDB_ADMIN_PASSWORD))
    print(response.headers)

    if response.status_code == 200:
        does_repo_exists = True

    return does_repo_exists

def create_repository(graphdb_url, repo_id, repo_description):

    while not check_triple_store_status(graphdb_url):
        print("Waiting for triple store come online")
        time.sleep(5)

    if not check_repository(graphdb_url, repo_id):
        print("repository was not found.  ...now creating")

        repo_config = None
        with open('templates/repo-config.mustache', 'r') as f:
            repo_config = chevron.render(f, {'id': repo_id, 'description': repo_description})

        file = open("config.ttl", "w")
        file.write(repo_config)
        file.close()

        config_file = open("config.ttl", "rb")
        url = graphdb_url + "/rest/repositories"

        response = requests.request("POST", url, files={"config": config_file}, auth = HTTPBasicAuth(GRAPHDB_ADMIN_USER,GRAPHDB_ADMIN_PASSWORD))
        print(response.headers)
        if response.status_code == 201:
            print(repo_id + " repository has been created")
    else:
        print(repo_id + " repository already exits")

def secure_graphdb(graphdb_url):
    url = graphdb_url + "/rest/security"

    payload = "true"
    headers = {'content-type': "application/json", 'accept': "text/plain"}
    response = requests.request("POST", url, data=payload, headers=headers,
                                auth = HTTPBasicAuth(GRAPHDB_ADMIN_USER,GRAPHDB_ADMIN_PASSWORD))
    print(response.text + "GraphDB is secured")

def main(graphdb_url):
    '''
    Create location repository in graph DB
    '''
    repo_id = FDP_PREFIX + "-location"
    repo_description = "Repository to store location information"
    create_repository(graphdb_url, repo_id, repo_description)

    '''
    Create germplasm repository in graph DB
    '''
    repo_id = FDP_PREFIX + "-germplasm"
    repo_description = "Repository to store germplasm RDF"
    create_repository(graphdb_url, repo_id, repo_description)

    '''
    Create administrative repository in graph DB
    '''
    repo_id = FDP_PREFIX + "-administrative"
    repo_description = "Repository to store administrative RDF"
    create_repository(graphdb_url, repo_id, repo_description)

    '''
    Create fdp repository in graph DB
    '''
    repo_id = FDP_PREFIX + "-fdp"
    repo_description = "Repository to store FAIR Data Point's metadata RDF documents"
    create_repository(graphdb_url, repo_id, repo_description)

    '''
    Secure graphdb so that only `admin` user access it 
    '''
    secure_graphdb(graphdb_url)

print("Repository manager script started")
if FDP_PREFIX == '':
  sys.exit("MUST SET FDP_PREFIX ENVIRONMENT VARIABLE")

if graphdb_url.endswith("/"):
    graphdb_url = graphdb_url[:-1]
print(graphdb_url)
main(graphdb_url)
