var fs = require('fs');
var exec = require('child_process').exec;

var modules = JSON.parse(fs.readFileSync('package.json', 'ascii')).browserifiedModules;

fs.watchFile('package.json', function() {
  fs.writeFileSync('scripts/modules.js', fileContents());
  exec('npm run build:browserify');
});

function fileContents() {
  var output = '// THIS IS A READONLY FILE - DO NOT HAND EDIT\n';

  for (var clientModuleName in modules) {
    if (Object.hasOwnProperty.call(modules, clientModuleName)) {
      var npmModuleName = modules[clientModuleName];
      output += moduleString(clientModuleName, npmModuleName);
    }
  }

  return output;
}

function moduleString(clientModuleName, npmModuleName) {
  return 'window[\'' + clientModuleName + '\'] = require(\'' + npmModuleName + '\');\n'
}
