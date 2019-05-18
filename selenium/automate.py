import subprocess
import sys
from urllib.parse import urljoin
from parse import search

import requests

BROWSERS = {
    'chrome-stable': {
        'browser': 'chrome',
        'repo_url': 'http://dl.google.com/linux/chrome/deb/dists/stable/main/binary-amd64/',
        'package_name': 'google-chrome-stable',
        'tag': 'stable'
    },
    'chrome-beta': {
        'browser': 'chrome',
        'repo_url': 'http://dl.google.com/linux/chrome/deb/dists/stable/main/binary-amd64/',
        'package_name': 'google-chrome-beta',
        'tag': 'beta'
    },
    'chrome-dev': {
        'browser': 'chrome',
        'repo_url': 'http://dl.google.com/linux/chrome/deb/dists/stable/main/binary-amd64/',
        'package_name': 'google-chrome-unstable',
        'tag': 'dev'
    },
    'yandex-beta': {
        'browser': 'yandex',
        'repo_url': 'https://repo.yandex.ru/yandex-browser/deb/dists/beta/main/binary-amd64/',
        'package_name': 'yandex-browser-beta',
        'tag': 'yandex-beta'
    },
    'opera-stable': {
        'browser': 'opera',
        'repo_url': 'http://deb.opera.com/opera-stable/dists/stable/non-free/binary-amd64/',
        'package_name': 'opera-stable',
        'tag': 'stable'
    }
}


def get_last_package_version(repo_url, package_name):
    packages_url = urljoin(repo_url, 'Packages')
    packages_text = requests.get(packages_url).text
    result = search(f"Package: {package_name}\nVersion: {{}}\n", packages_text)
    return result.fixed[0] if result else None


def get_chromedriver_version(browser_version):
    browser_version = int(browser_version.split('.')[0]) if isinstance(browser_version, str) else browser_version
    release_url = f"https://chromedriver.storage.googleapis.com/LATEST_RELEASE_{browser_version}"
    r = requests.get(release_url)
    if r.status_code == 200:
        return r.text
    else:
        return get_chromedriver_version(browser_version - 1)


def get_operadriver_version():
    r = requests.get('https://api.github.com/repos/operasoftware/operachromiumdriver/releases/latest')
    return f".{r.json()['name']}"


def get_driver_version(browser, browser_version):
    if browser == 'chrome':
        return get_chromedriver_version(browser_version)
    if browser in ('yandex', 'opera'):
        return get_operadriver_version()


def main():
    for browser, browser_info in BROWSERS.items():
        version = get_last_package_version(browser_info['repo_url'], browser_info['package_name'])
        driver_version = get_driver_version(browser_info['browser'], version)

        cmd = ['sh', f"automate_{browser_info['browser']}.sh", version, driver_version, browser_info['tag']]
        print(cmd)
        subprocess.run(cmd, stdout=sys.stdout, stderr=sys.stderr, input=b'n')


if __name__ == '__main__':
    main()
