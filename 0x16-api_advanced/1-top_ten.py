#!/usr/bin/python3
"""
Project 1
"""
import requests


def number_of_subscribers(subreddit):
    """ Checks number of subscribers to a given subreddit """
    headers = {"User-Agent": 'KathleenRMcK'}
    req_help = requests.get("https://www.reddit.com/r/{}about.json".format(
    subreddit), headers=headers)
    if req_help.status_code == 404:
        return (0)
    else:
        return_help = req_help.json()
        for data_help in return_help["data"]["subscribers"]:
            print(data_help["data"])
