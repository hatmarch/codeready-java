if [ -z $1 ]; then
    echo "Usage: Name of project"
fi

echo "Passed in: $1."

CICD_NAMESPACE=$1
HOSTNAME=che-${CICD_NAMESPACE}.openshift.89bc1b3f90534e539ef1.eastus2.azmosa.io
# set HOSTNAME = $(oc get route jenkins -o template --template='{{.spec.host}}' | sed "s/jenkins-${CICD_NAMESPACE}.//g")

oc project ${CICD_NAMESPACE}

echo "Namespace is $CICD_NAMESPACE.  Host is: $HOSTNAME.  Arg is: $1."

oc process -f https://raw.githubusercontent.com/minishift/minishift/master/addons/che/templates/che-workspace-service-account.yaml \
                  --param SERVICE_ACCOUNT_NAMESPACE=${CICD_NAMESPACE} --param=SERVICE_ACCOUNT_NAME=che-workspace | oc create -f -

oc process -f https://raw.githubusercontent.com/minishift/minishift/master/addons/che/templates/che-server-template.yaml \
                --param ROUTING_SUFFIX=$HOSTNAME \
                --param CHE_MULTIUSER=false \
                --param CHE_VERSION="7.1.0" \
                --param CHE_INFRA_OPENSHIFT_PROJECT=$CICD_NAMESPACE \
                --param CHE_INFRA_KUBERNETES_SERVICE__ACCOUNT__NAME=che-workspace | oc create -f -

# oc process -f https://raw.githubusercontent.com/minishift/minishift/master/addons/che/templates/che-server-template.yaml \
#                 --param ROUTING_SUFFIX=$HOSTNAME \
#                --param CHE_MULTIUSER=true \
#                --param CHE_VERSION="7.3.0" \
#                 --param CHE_INFRA_OPENSHIFT_PROJECT=$CICD_NAMESPACE \
#                 --param CHE_INFRA_KUBERNETES_SERVICE__ACCOUNT__NAME=che-workspace | oc create -f -

oc set resources dc/che --limits=cpu=1,memory=2Gi --requests=cpu=200m,memory=512Mi