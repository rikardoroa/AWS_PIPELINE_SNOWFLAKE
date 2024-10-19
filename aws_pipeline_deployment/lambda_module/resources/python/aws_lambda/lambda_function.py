import json
from api_calls import ApiDataCapture
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    try:

        call = ApiDataCapture()
        call.get_api_pagination_calls()

        return {
            'statusCode': 200,
            'body': json.dumps('data stored in dev bucket')
        }

    except Exception as e:
        logger.error(f'can not execute the stream the data, please review the process:{e}')
