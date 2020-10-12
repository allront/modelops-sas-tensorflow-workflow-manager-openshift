# 3_retrain.sh
# 3_retrain.sh executes the retraining pipeline in docker images
#
# Variables:
#
# Steps:
#   0 - Transform and Load the performance tables
#   1 - Train the tensorflow model
#   2 - Register the model in SAS Model Manager with a new version

# 0 - Transform and Load the performance tables
echo "$(date '+%x %r') INFO Setup Transform_Load container..."



