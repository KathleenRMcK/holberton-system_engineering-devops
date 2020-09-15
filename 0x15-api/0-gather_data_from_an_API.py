#!/usr/bin/python3
"""
Using REST API for employee ID
Returns ingo about TODO list progress
"""
import requests
from sys import argv


if __name__ == "__main__":
    if len(argv) > 1:
        username = argv[1]
        url = "https://jsonplaceholder.typicode.com/"
        request_ = requests.get("{}users/{}".format(url, username))
        name_ = request_.json().get("name")
        if name_ is not None:
            req_holder = requests.get("{}todos?userId={}".format(
                url, username))
            len_helper = len(req_holder)
            task_holder = []
            for help in req_holder:
                if help.get("completed") is True:
                    task_holder.append(help)
            count_help = len(task_holder)
            print("Employee {} is done with tasks({}/{}):".format(
                name_, count_help, len_helper))
            for holder in task_holder:
                print("\t {}".format(holder.get("title")))
