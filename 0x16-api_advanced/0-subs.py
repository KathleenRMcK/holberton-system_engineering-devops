#!/usr/bin/python3
"""
Project 0
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
        return(return_help["data"]["subscribers"])
