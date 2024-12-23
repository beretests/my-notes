import sys
import requests
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
import logging

# Logging setup
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Function to check if the content is present on the website
def check_website_content(url, content_to_check):
    logging.info(f"Checking website content at {url}")
    response = requests.get(url)
    if response.status_code != 200:
        logging.error(f"Failed to load website content (status code: {response.status_code})")
        return False

    soup = BeautifulSoup(response.text, 'html.parser')
    if content_to_check in soup.text:
        logging.info(f"Content '{content_to_check}' found on the page.")
        return True
    else:
        logging.error(f"Content '{content_to_check}' NOT found on the page.")
        return False

# Function to check the status of assets (images, CSS, JS)
def check_assets(url):
    logging.info(f"Checking assets on {url}")
    response = requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')

    asset_tags = {
        'img': 'src',
        'link': 'href',  # For stylesheets and icons
        'script': 'src'  # For JavaScript files
    }

    all_assets_loaded = True

    for tag, attr in asset_tags.items():
        for asset in soup.find_all(tag):
            asset_url = asset.get(attr)
            if asset_url:
                # Ensure the asset URL is absolute
                if not asset_url.startswith('http'):
                    asset_url = requests.compat.urljoin(url, asset_url)

                # Check asset load status
                try:
                    asset_response = requests.get(asset_url, timeout=5)
                    if asset_response.status_code == 200:
                        logging.info(f"Asset loaded successfully: {asset_url}")
                    else:
                        logging.error(f"Failed to load asset {asset_url} (status code: {asset_response.status_code})")
                        all_assets_loaded = False
                except requests.RequestException as e:
                    logging.error(f"Error loading asset {asset_url}: {e}")
                    all_assets_loaded = False

    return all_assets_loaded

# Function to check if assets are visually displayed using Selenium
def check_visual_assets(url):
    logging.info(f"Checking visual assets on {url} using Selenium")

    # Setup Selenium (Headless Chrome)
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    service = Service('path_to_chromedriver')  # Provide the correct path to your ChromeDriver
    driver = webdriver.Chrome(service=service, options=chrome_options)

    try:
        driver.get(url)

        # Check for missing images
        missing_images = False
        images = driver.find_elements(By.TAG_NAME, 'img')
        for img in images:
            if not img.is_displayed():
                missing_images = True
                logging.error(f"Image not displayed: {img.get_attribute('src')}")

        # Check for console errors (e.g., JS, CSS issues)
        logs = driver.get_log('browser')
        asset_errors = False
        for log in logs:
            if "Failed to load" in log['message']:
                logging.error(f"Asset load error: {log['message']}")
                asset_errors = True

        if not missing_images and not asset_errors:
            logging.info("All visual assets loaded successfully.")
        else:
            logging.error("Some visual assets failed to load.")
            return False

        return True
    finally:
        driver.quit()

# Function to run both content and asset validation steps
def validate_website(url, content_to_check, cdn_url_pattern=None):
    logging.info(f"Starting validation for {url}")

    # Step 1: Check website content
    content_valid = check_website_content(url, content_to_check)

    # Step 2: Check if assets are loading (including CDN assets if pattern is provided)
    assets_valid = check_assets(url)

    # Step 3: Check visual asset loading using Selenium
    visual_assets_valid = check_visual_assets(url)

    # Final validation summary
    if content_valid and assets_valid and visual_assets_valid:
        logging.info("Website validation successful: All content and assets loaded properly.")
        return True
    else:
        logging.error("Website validation failed: Some content or assets did not load properly.")
        return False

# URL of the website to check
website_url = "https://example.com"

# Content to check on the website
content_to_check = "Release Successful"

# Run the validation
validate_website(website_url, content_to_check)
