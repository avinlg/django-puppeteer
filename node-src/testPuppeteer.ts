import * as puppeteer from 'puppeteer';

async function testPuppeteer() {
    const browser = await puppeteer.launch();
    const page = await browser.newPage();
    await page.setViewport({ width: 1366, height: 768 });
    await page.goto('https://avinlg.github.io/');

    await page.screenshot({
        path: 'test-out/test.png'
    });
    await browser.close();
}

testPuppeteer();