#!/usr/bin/python3
"""
Extend project 0 with specific requirements
"""
import csv
import requests
from sys import argv


if __name__ == "__main__":
    username = argv[1]
    url_r = "https://jsonplaceholder.typicode.com/users/{}".format(username)
    request_ = requests.get(url_r, verify=False).json()
    url_t = "https://jsonplaceholder.typicode.com/todos?userId={}".format(
        username)
    todo_ = requests.get(url_t, verify=False).json()
    with open("{}.csv".format(username), 'w', newline='') as csvfile:
        write_help = csv.writer(csvfile, quoting=csv.QUOTE_ALL)
        for holder in todo:
            write_help.writerow([int(username), request_.get('username'),
            holder.get('completed'), holder.get('title')])
