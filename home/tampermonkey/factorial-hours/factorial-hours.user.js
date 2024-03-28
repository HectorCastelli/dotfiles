// ==UserScript==
// @name         Factorial HR spanish hours
// @version      2024-03-11
// @description  Automate the input of shifts in factorial
// @author       You
// @match        https://app.factorialhr.com/attendance/clock-in/*
// @icon         data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==
// @grant        none
// @run-at       document-idle
// ==/UserScript==

const weekendColor = 'rgb(250, 250, 250)';
const currentDayColor = 'rgb(254, 248, 238)';

const shifts = [
    ["09:00", "13:00"],
    ["14:00", "18:00"]
];


(async function () {
    'use strict';

    console.log("Waiting...");
    await new Promise(r => setTimeout(r, 15000));

    alert("Start shift helper");

    const inputTable = document.querySelector("#factorialRoot > div > div._110my71a > div > main > div > div > div > div.purg7v1.purg7vc9._15se5fi0.mn5ir72.mn5ir70.undefined > div > div.OdhHT > div.purg7v1.purg7vx.purg7vc9._15se5fio._15se5fi1._15se5fi1v > div > div > table > tbody");


    const urlData = document.URL.split("/");
    const month = urlData.pop();
    const year = urlData.pop();
    let day = 0;

    for (const row of inputTable.rows) {
        day++;
        console.info("Will try to fill hours", row, `${year}-${month.padStart(2, "0")}-${day.toString().padStart(2, "0")}`);
        if (row.style.backgroundColor == weekendColor) {
            console.info("Skipping. Row is a weekend", row);
            continue;
        }
        const shiftCell = row.cells[1].firstChild;
        const cellChildCount = shiftCell.childNodes.length;
        for (let i = cellChildCount; i < 3; i++) {
            const shift = shifts[i - 1];
            console.log("Adding shift", shift, day);
            await addShift(shift[0], shift[1], day, month, year);
        }

        if (row.style.backgroundColor == currentDayColor) {
            console.info("This was the the last available row. Finishing");
            alert("Finished adding shifts until today");
            break;
        }
    }
})();


function addShift(shiftStart, shiftEnd, day, month, year) {
    const payload = {
        "clock_in": shiftStart,
        "clock_out": shiftEnd,
        "day": day,
        "period_id": 13402019,
        "workable": true,
        "location_type": null,
        "time_settings_break_configuration_id": null,
        "minutes": null,
        "date": `${year}-${month.padStart(2, "0")}-${day.toString().padStart(2, "0")}`,
        "source": "desktop"
    };
    const headers = {
        "accept": "application/json, text/plain, */*",
        "accept-language": "en-GB,en-US;q=0.9,en;q=0.8",
        "content-type": "application/json",
        "sec-ch-ua": "\"Chromium\";v=\"122\", \"Not(A:Brand\";v=\"24\", \"Google Chrome\";v=\"122\"",
        "sec-ch-ua-mobile": "?0",
        "sec-ch-ua-platform": "\"macOS\"",
        "sec-fetch-dest": "empty",
        "sec-fetch-mode": "cors",
        "sec-fetch-site": "same-site",
        "x-factorial-access": "1658959",
        "x-factorial-origin": "web"
    };
    return fetch("https://api.factorialhr.com/attendance/shifts", {
        "headers": headers,
        "referrer": "https://app.factorialhr.com/",
        "referrerPolicy": "strict-origin-when-cross-origin",
        "body": JSON.stringify(payload),
        "method": "POST",
        "mode": "cors",
        "credentials": "include"
    });
}