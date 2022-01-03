/**
 * This file schedules a cronjob which will automatically
 * download the NYT daily crossword 1 minute after its
 * published and then upload it to Dropbox.
 *
 * @author Nathan Buchar <hello@nathanbuchar.com>
 */

const cron = require('cron');
const dropbox = require('dropbox');
const https = require('https');
const path = require('path');

// Instantiates the Dropbox client so that later we can
// upload the downloaded crossword PDF files to Dropbox.
//
// Take note of the `DROPBOX_ACCESS_TOKEN` env variable. To
// generate one, please visit https://dropbox.tech/developers/generate-an-access-token-for-your-own-account.
const dbx = new dropbox.Dropbox({
    accessToken: process.env.DROPBOX_ACCESS_TOKEN,
});

// Gets the NYT crossword for a specific date.
function getNYTCrossword(date) {
    const year = new Intl.DateTimeFormat('en-US', { year: 'numeric', timeZone: 'America/New_York' }).format(date);
    const yy = new Intl.DateTimeFormat('en-US', { year: '2-digit', timeZone: 'America/New_York' }).format(date);
    const mon = new Intl.DateTimeFormat('en-US', { month: 'short', timeZone: 'America/New_York' }).format(date);
    const mm = new Intl.DateTimeFormat('en-US', { month: '2-digit', timeZone: 'America/New_York' }).format(date);
    const dd = new Intl.DateTimeFormat('en-US', { day: '2-digit', timeZone: 'America/New_York' }).format(date);
    const day = new Intl.DateTimeFormat('en-US', { weekday: 'short', timeZone: 'America/New_York' }).format(date);

    console.log('Attempting to download crossword...');

    // Make an authenticated request to where we believe the
    // crossword is stored. As of Jan 2022, the NYT crossword
    // is stored at this location with a filename in the
    // format of `MMMDDYY`. Ex. Jan0122.pdf.
    //
    // As part of the headers, we send our NYT cookie. This
    // needs to be copied from an authenticated NYT session.
    // This cookie requires at least the following: nyt-a,
    // NYT-S, nyt-auth-method, and nyt-m.
    const req = https.request({
        protocol: 'https:',
        host: 'www.nytimes.com',
        path: `/svc/crosswords/v2/puzzle/print/${mon}${dd}${yy}.pdf`,
        method: 'GET',
        headers: {
            Referer: 'https://www.nytimes.com/crosswords/archive/daily',
            // Cookie requires nyt-a, NYT-S, nyt-auth-method, and nyt-m.
            Cookie: process.env.NYT_COOKIE,
        },
    }, (res) => {
        if (res.statusCode === 200) {
            const data = [];

            res.on('error', (err) => {
                console.log(err);
            });

            res.on('data', (chunk) => {
                data.push(chunk);
            });

            res.on('end', () => {
                console.log('Successfully downloaded crossword');

                // The file has successfully downloaded, and now
                // we will upload it to Dropbox by concatenating
                // the data chunks into a buffer.
                //
                // Take note of the `DROPBOX_FILE_PATH` environment
                // variable. For Supernote devices, this will be
                // `/Supernote/Document`.
                //
                // As as it's coded below, crosswords will be uploaded to:
                // `/Supernote/Document/Crosswords` and the filename
                // will be in the format `YYYYMMDD_ddd-crossword.pdf`.
                dbx.filesUpload({
                    path: path.join(process.env.DROPBOX_FILE_PATH, `Crosswords/${year}${mm}${dd}_${day}-crossword.pdf`),
                    contents: Buffer.concat(data),
                }).then((response) => {
                    console.log('Successfully uploaded crossword');
                    console.log(`Content hash: ${response.result.content_hash}`);
                }).catch((err) => {
                    console.log('Error writing to dropbox');
                    console.log(err);
                });
            });
        } else {
            // The crossword is seemingly not yet available.
            // Try again in an hour.
            setTimeout(() => getNYTCrossword(date), 1000 * 60 * 60);
        }
    });

    req.on('error', (err) => {
        console.log(err);
    });

    req.end();
}

// Gets the NYT crossword for tomorrow's date, since it's
// released between 2 and 6 hours before midnight.
function getTomorrowsNYTCrossword() {
    const today = new Date();
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    getNYTCrossword(tomorrow);
}

// Lambda entrypoint
exports.handler = async function (event, context) {
    console.log("EVENT: \n" + JSON.stringify(event, null, 2))
    return getTomorrowsNYTCrossword()
}
