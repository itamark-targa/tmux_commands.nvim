local M = {}
M.tmux_target_pane = nil

function M.print_curr_line()
    local line = vim.api.nvim_get_current_line()
    -- find the targe pane in current window that runs python
    if M.tmux_target_pane == nil then
        -- print("DBG: tmux_target_pane is nil, try to get it")
        local cmd = "tmux list-panes -F '#{pane_current_command} #{pane_index}' | grep python | awk '{print $2}'"
        local handle = io.popen(cmd)
        if handle ~= nil then
            local result = handle:read("*a")
            handle:close()
            -- I expect to get a single pane index + newline (assuming we don't have > 10 panes)
            if string.len(result) == 2 then
                M.tmux_target_pane = result:gsub("\n", "")
                -- print("DBG: got tmux pane:" .. M.tmux_target_pane)
            else
                print('Warning: no Python process found in tmux window, send-line is disabled')
            end
        end
    end

    if M.tmux_target_pane ~= nil then
        -- print("DBG: sending to pane:" .. M.tmux_target_pane)
        line = line:gsub('"', '\\"') -- we need to escape the double quotes when using tmux send-keys
        vim.fn.system("tmux send-keys -t " .. M.tmux_target_pane .. " -l \"" .. line .. "\r\"")
        --vim.fn.system("tmux send-keys -t " .. M.tmux_target_pane .. " Enter")
    end
end

function M.setup(opts)
    --print("in tmux_commands setup:")
    opts = opts or {}
    -- set the curser line style and enable it TODO set the enable flag in opts
    vim.cmd('hi CursorLine cterm=NONE ctermbg=24 ctermfg=white guibg=#004d9a guifg=white')
    vim.cmd('autocmd FileType python setlocal cul')

    if opts.culopt == 'line' then
        vim.cmd('set cursorlineopt=line')
    elseif opts.culopt == 'number' then
        vim.cmd('set cursorlineopt=number')
    elseif opts.culopt == 'both' then
        vim.cmd('set cursorlineopt=both')
    end

    vim.keymap.set("n", "<F9>", M.print_curr_line)
    --[[ This was the original example from the tutorial:
    vim.keymap.set("n", "<Leader>h", function()
        if opts.name then
            print("hello, " .. opts.name)
        else
            print("hello")
        end
    end)
    ]]
end

return M
