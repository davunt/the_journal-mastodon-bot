"""
    Entry file for lambda functions
"""
import os
from datetime import datetime, timedelta, timezone

import feedparser
from mastodon import Mastodon
from utils import content_warnings, hashtags

feed_url = os.environ.get("feed_url")
masto_api_base_url = os.environ.get("masto_api_base_url")
masto_access_token = os.environ.get("masto_access_token")

MINUTE_INTERVAL = 120


def apply_hashtags(text):
    """apply hashtags to post text"""
    for hashtag in hashtags:
        text = text.replace(hashtag, f"#{hashtag}")
    return text


def get_content_warning(_text):
    """Search post for potential trigger words that should have a content warning"""
    text = _text.lower()
    for warning, triggers in content_warnings.items():
        for trigger in triggers:
            if trigger in text.split():
                return f"Mentions {warning.capitalize()}"


def get_latest_articles():
    """get all articles from last 60 minutes"""
    posts = []
    now = datetime.now(timezone.utc)
    feed = feedparser.parse(feed_url)

    for entry in feed.entries:
        time_range = timedelta(minutes=MINUTE_INTERVAL)
        entry_date = datetime.strptime(entry.published, "%a, %d %b %Y %H:%M:%S %z")
        if now - entry_date <= time_range:
            post_text = f"{entry.title}\n\n{apply_hashtags(entry.summary)}"[:450]
            if len(post_text) == 450:
                post_text = "f{post_text}..."
            posts.append(f"{post_text} #press #irishpress\n\n{entry.link}")

    return posts


def schedule_posts(posts):
    """calculate how many minutes should separate each post"""
    mastodon = Mastodon(
        access_token=masto_access_token,
        api_base_url=masto_api_base_url,
    )

    if len(posts) > 0:
        post_interval = MINUTE_INTERVAL / len(posts)
        post_datetime = datetime.now() + timedelta(minutes=5)
        for post in posts:
            print(post_interval)
            print(post_datetime)
            print(post)
            post_datetime += timedelta(minutes=post_interval)
            content_warning = get_content_warning(post)
            print(content_warning)
            mastodon.status_post(
                post, scheduled_at=post_datetime, spoiler_text=content_warning
            )
            print("---------------------------")

    print(f"Number of posts {len(posts)}")


def handler(_event, _context):
    """Entry function for lambda"""
    posts = get_latest_articles()
    schedule_posts(posts)
