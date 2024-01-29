#!/usr/bin/env node

// First get list of all iGuides and filter out stuff you need:
//   $ curl https://youriguide.com/api/v1/map/ | jq . | gvim -
// Then run the script below on filtered results

const fs = require('fs');

const inputFile = process.argv[2] || '/dev/stdin';

fs.readFileSync(inputFile, 'utf8').split('\n')
  .map(l => {
    l = l.replace(/^\s*"?\s*/, '').replace(/\s*"?\s*$/, '');
    if (!l) {
      return;
    }

    const cols = l.split('|');
    return {
      alias: cols[0],
      city: cols[1],
      address: cols[2],
      agent: cols[3],
      brokerage: cols[4],
      flags: parseInt(cols[5]),
      lat: parseFloat(cols[6]),
      lng: parseFloat(cols[7]),
    };
  })
  .filter(e => !!e)

  .map(e => ({
    ...e,
    url: `https://youriguide.com/${e.alias}`,
    isLocked: e.flags & 0x01,
  }))

  .forEach(e => {
    const { alias, agent, brokerage, isLocked } = e;

    if (isLocked) {
      return;
    }

    console.log(`* https://youriguide.com/${alias} by ${agent}, ${brokerage}`);
  });
