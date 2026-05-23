local HOTKEYS = 'Update (U) | Quit (q)'
local CHECK_CONCURRENCY = 4

local function with_hotkeys(lines)
  local out = { HOTKEYS }
  vim.list_extend(out, lines)
  return out
end

local function open_scratch_float(title, lines)
  local width = math.min(100, math.max(50, math.floor(vim.o.columns * 0.8)))
  local height = math.min(30, math.max(8, math.floor(vim.o.lines * 0.7)))
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].filetype = 'packupdates'
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, with_hotkeys(lines))
  vim.bo[buf].modifiable = false

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' ' .. title .. ' ',
    title_pos = 'center',
  })

  vim.wo[win].wrap = false
  vim.wo[win].cursorline = true

  local close = function()
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
  end

  vim.keymap.set('n', 'q', close, { buffer = buf, silent = true })
  vim.keymap.set('n', '<Esc>', close, { buffer = buf, silent = true })

  return buf
end

local function set_float_lines(buf, lines)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, with_hotkeys(lines))
  vim.bo[buf].modifiable = false
end

local function run_cmd(cmd, cwd)
  local result = vim.system(cmd, { cwd = cwd, text = true }):wait(30000)
  return result.code, vim.trim(result.stdout or ''), vim.trim(result.stderr or '')
end

local function git(cwd, args)
  local cmd = { 'git' }
  vim.list_extend(cmd, args)
  return run_cmd(cmd, cwd)
end

local function git_async(cwd, args, callback)
  local cmd = { 'git' }
  vim.list_extend(cmd, args)

  vim.system(cmd, { cwd = cwd, text = true }, function(result)
    vim.schedule(function()
      callback(result.code, vim.trim(result.stdout or ''), vim.trim(result.stderr or ''))
    end)
  end)
end

local function short_sha(sha) return sha and sha:sub(1, 8) or '' end

local function clean_version(version)
  if type(version) ~= 'string' then return version end
  return (version:gsub("^'(.*)'$", '%1'))
end

local function rev_parse(path, ref)
  local code, out = git(path, { 'rev-parse', '--verify', ref })
  if code == 0 and out ~= '' then return out end
end

local function commit_for_ref(path, ref) return rev_parse(path, ref .. '^{commit}') or rev_parse(path, ref) end

local function target_for_version_range(path, version)
  local code, out = git(path, { 'tag', '--list' })
  if code ~= 0 then return nil, 'could not list tags' end

  local best = nil
  for tag in out:gmatch '[^\r\n]+' do
    local parsed = vim.version.parse(tag)
    if parsed and version:has(parsed) and (not best or parsed > best.version) then best = { tag = tag, version = parsed } end
  end

  if not best then return nil, 'no matching tag for ' .. tostring(version) end
  return commit_for_ref(path, 'refs/tags/' .. best.tag), best.tag
end

local function target_for_plugin(plugin)
  local path = plugin.path
  local version = clean_version(plugin.spec.version)

  if type(version) == 'table' and getmetatable(version) and getmetatable(version).__index and getmetatable(version).__index.has then
    return target_for_version_range(path, version)
  end

  if type(version) == 'string' and version ~= '' then
    local target = rev_parse(path, 'refs/remotes/origin/' .. version)
    if target then return target, 'origin/' .. version end

    target = commit_for_ref(path, 'refs/tags/' .. version)
    if target then return target, version end

    target = rev_parse(path, version)
    if target then return target, version end

    return nil, 'could not resolve ' .. version
  end

  local code, ref = git(path, { 'symbolic-ref', '--quiet', '--short', 'refs/remotes/origin/HEAD' })
  if code ~= 0 or ref == '' then ref = 'origin/HEAD' end

  local target = rev_parse(path, ref)
  if target then return target, ref end

  return nil, 'could not resolve default branch'
end

local function lockfile_path() return vim.fs.joinpath(vim.fn.stdpath 'config', 'nvim-pack-lock.json') end

local function encode_json(value, indent)
  indent = indent or ''
  local next_indent = indent .. '  '

  if type(value) ~= 'table' then return vim.json.encode(value) end

  local keys = vim.tbl_keys(value)
  table.sort(keys)

  local lines = { '{' }
  for i, key in ipairs(keys) do
    local suffix = i == #keys and '' or ','
    lines[#lines + 1] = next_indent .. vim.json.encode(key) .. ': ' .. encode_json(value[key], next_indent) .. suffix
  end
  lines[#lines + 1] = indent .. '}'
  return table.concat(lines, '\n')
end

local function update_lockfile(updates)
  local path = lockfile_path()
  local text = table.concat(vim.fn.readfile(path), '\n')
  local ok, lock = pcall(vim.json.decode, text)
  if not ok or type(lock) ~= 'table' or type(lock.plugins) ~= 'table' then return false, 'could not parse ' .. path end

  for _, update in ipairs(updates) do
    lock.plugins[update.name] = lock.plugins[update.name] or {}
    lock.plugins[update.name].rev = update.target
  end

  local encoded = encode_json(lock)
  vim.fn.writefile(vim.split(encoded, '\n'), path)
  return true
end

local function apply_updates(updates, on_progress)
  local errors = {}

  for index, update in ipairs(updates) do
    if on_progress then on_progress(update, index, #updates, 'checkout') end

    local checkout_code, _, checkout_err = git(update.path, { 'checkout', '--quiet', update.target })
    if checkout_code ~= 0 then
      errors[#errors + 1] = ('%s: %s'):format(update.name, checkout_err ~= '' and checkout_err or 'git checkout failed')
    else
      local current = rev_parse(update.path, 'HEAD')
      if current ~= update.target then
        errors[#errors + 1] = ('%s: checkout ended at %s, expected %s'):format(update.name, short_sha(current), short_sha(update.target))
      end

      if on_progress then on_progress(update, index, #updates, 'submodules') end

      local submodule_code, _, submodule_err = git(update.path, { 'submodule', 'update', '--init', '--recursive' })
      if submodule_code ~= 0 then
        errors[#errors + 1] = ('%s: %s'):format(update.name, submodule_err ~= '' and submodule_err or 'git submodule update failed')
      end

      local doc_dir = vim.fs.joinpath(update.path, 'doc')
      if vim.uv.fs_stat(doc_dir) then
        if on_progress then on_progress(update, index, #updates, 'helptags') end

        vim.fn.delete(vim.fs.joinpath(doc_dir, 'tags'))
        pcall(vim.cmd.helptags, { doc_dir, magic = { file = false } })
      end
    end
  end

  if #errors == 0 then
    if on_progress then on_progress(nil, #updates, #updates, 'lockfile') end

    local ok, err = update_lockfile(updates)
    if not ok then errors[#errors + 1] = err end
  end

  return errors
end

local function render_updates(updates, errors)
  local lines = { '' }
  if #updates == 0 then
    lines[#lines + 1] = 'All vim.pack packages are up to date.'
  else
    lines[#lines + 1] = ('%d package%s with available updates:'):format(#updates, #updates == 1 and '' or 's')
    lines[#lines + 1] = ''
    for _, update in ipairs(updates) do
      lines[#lines + 1] = update.name
      lines[#lines + 1] = ('  %s -> %s  (%s)'):format(short_sha(update.current), short_sha(update.target), update.target_label)
    end
  end

  if #errors > 0 then
    lines[#lines + 1] = ''
    lines[#lines + 1] = 'Skipped:'
    for _, err in ipairs(errors) do
      lines[#lines + 1] = '  ' .. err
    end
  end

  return lines
end

local function find_updates_async(on_progress, on_done)
  local ok, plugins = pcall(vim.pack.get, nil, { info = false })
  if not ok then
    on_done(nil, { 'Could not read vim.pack packages: ' .. tostring(plugins) })
    return
  end

  table.sort(plugins, function(a, b) return a.spec.name < b.spec.name end)

  local updates = {}
  local errors = {}
  local active = {}
  local completed = 0
  local next_index = 1
  local running = 0
  local total = #plugins

  local function active_names()
    local names = vim.tbl_keys(active)
    table.sort(names)
    return names
  end

  local function report_progress()
    if on_progress then on_progress(active_names(), completed, total) end
  end

  local function finish_plugin(plugin, fetch_code, fetch_err)
    local name = plugin.spec.name
    active[name] = nil
    running = running - 1
    completed = completed + 1

    if fetch_code ~= 0 then
      errors[#errors + 1] = ('%s: %s'):format(name, fetch_err ~= '' and fetch_err or 'git fetch failed')
    else
      local target, target_label = target_for_plugin(plugin)
      local current = rev_parse(plugin.path, 'HEAD') or plugin.rev
      if target and current and target ~= current then
        updates[#updates + 1] = {
          name = name,
          path = plugin.path,
          current = current,
          target = target,
          target_label = target_label,
        }
      elseif not target then
        errors[#errors + 1] = ('%s: %s'):format(name, target_label or 'could not resolve target')
      end
    end

    report_progress()
  end

  local function start_next()
    while running < CHECK_CONCURRENCY and next_index <= total do
      local plugin = plugins[next_index]
      next_index = next_index + 1
      running = running + 1
      active[plugin.spec.name] = true
      report_progress()

      git_async(plugin.path, { 'fetch', '--quiet', '--tags', '--force', '--recurse-submodules=yes', 'origin' }, function(fetch_code, _, fetch_err)
        finish_plugin(plugin, fetch_code, fetch_err)

        if completed == total then
          table.sort(updates, function(a, b) return a.name < b.name end)
          table.sort(errors)
          on_done(updates, errors)
        else
          start_next()
        end
      end)
    end
  end

  if total == 0 then
    on_done(updates, errors)
    return
  end

  start_next()
end

vim.api.nvim_create_user_command('PackUpdates', function()
  local current_updates = {}
  local checking = false
  local buf = open_scratch_float('vim.pack updates', { '', 'Checking...' })

  local refresh
  refresh = function()
    checking = true
    set_float_lines(buf, { '', 'Checking...' })

    vim.defer_fn(function()
      find_updates_async(function(names, completed, total)
        local label = #names > 0 and table.concat(names, ', ') or 'finishing...'
        set_float_lines(buf, {
          '',
          ('Checking: %s (%d/%d)'):format(label, completed, total),
        })
        vim.cmd.redraw()
      end, function(updates, errors)
        checking = false
        current_updates = updates or {}
        set_float_lines(buf, updates and render_updates(updates, errors) or { '', 'Could not check package updates:', '', unpack(errors) })
      end)
    end, 10)
  end

  vim.keymap.set('n', 'U', function()
    if checking then
      vim.notify('vim.pack update check is still running', vim.log.levels.WARN)
      return
    end

    if #current_updates == 0 then
      vim.notify('No vim.pack updates to apply', vim.log.levels.INFO)
      return
    end

    local names = vim.tbl_map(function(update) return update.name end, current_updates)

    set_float_lines(buf, {
      '',
      ('Updating %d package%s...'):format(#names, #names == 1 and '' or 's'),
      '',
      table.concat(names, ', '),
    })

    vim.defer_fn(function()
      local ok, errors = pcall(apply_updates, current_updates, function(update, index, total, stage)
        local line
        if update then
          line = ('Updating: %s (%d/%d) - %s'):format(update.name, index, total, stage)
        else
          line = 'Updating: lockfile'
        end

        set_float_lines(buf, { '', line })
        vim.cmd.redraw()
      end)
      if not ok then
        set_float_lines(buf, { '', 'Update failed:', '', tostring(errors) })
        return
      end

      if #errors > 0 then
        local lines = { '', 'Update failed:', '' }
        vim.list_extend(lines, errors)
        set_float_lines(buf, lines)
        return
      end

      current_updates = {}
      local lines = {
        '',
        ('Updated %d package%s:'):format(#names, #names == 1 and '' or 's'),
        '',
      }
      for _, name in ipairs(names) do
        lines[#lines + 1] = '  ' .. name
      end
      lines[#lines + 1] = ''
      lines[#lines + 1] = 'Run :PackUpdates again to recheck.'
      set_float_lines(buf, lines)
    end, 10)
  end, { buffer = buf, silent = true, desc = 'Update all listed vim.pack packages' })

  refresh()
end, { desc = 'Show vim.pack packages with available updates in a floating window' })
