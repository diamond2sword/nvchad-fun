local git_cmd = require('fn.git.cmd')

return function()
  git_cmd('login')
end
