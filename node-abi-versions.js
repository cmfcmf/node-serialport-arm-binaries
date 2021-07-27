const nodeAbi = require('node-abi')

process.stdout.write(
  JSON.stringify(nodeAbi.allTargets
    .filter(each => each.runtime === "node")
    .filter(each => parseInt(each.abi) >= 72)
  )
);