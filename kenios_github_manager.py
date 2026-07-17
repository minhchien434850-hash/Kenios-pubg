#!/usr/bin/env python3
"""KENIOS HAX - GitHub Repository Manager"""
import os, json, sys
from datetime import datetime, timezone
try:
    from github import Github, GithubException
except ImportError:
    print("Install PyGithub: pip install PyGithub")
    sys.exit(1)

TOKEN = os.environ.get("GITHUB_TOKEN", "YOUR_TOKEN")
REPO = "kenios-ipa"
OWNER = "kenios-hax"

class Manager:
    def __init__(self): self.g = Github(TOKEN); self.repo = None
    def connect(self):
        try:
            u = self.g.get_user()
            print(f"✅ Connected: {u.login}")
            return True
        except: return False
    def get_repo(self):
        try:
            self.repo = self.g.get_user().get_repo(REPO)
            print(f"✅ Repo: {self.repo.html_url}")
        except:
            self.repo = self.g.get_user().create_repo(REPO, description="KENIOS HAX - PUBG Mobile iOS Hack (16.0-26.5)")
            print(f"✅ Created: {self.repo.html_url}")
    def upload(self, path, content, msg="Update"):
        try:
            try:
                s = self.repo.get_contents(path)
                self.repo.update_file(path, msg, content, s.sha)
            except:
                self.repo.create_file(path, msg, content)
            print(f"✅ {path}")
        except Exception as e: print(f"❌ {path}: {e}")
    def stats(self):
        return {"stars": self.repo.stargazers_count, "forks": self.repo.forks_count}

def main():
    m = Manager()
    if not m.connect(): sys.exit(1)
    m.get_repo()
    s = m.stats()
    print(f"⭐ Stars: {s['stars']} | 🍴 Forks: {s['forks']}")

if __name__ == "__main__": main()
