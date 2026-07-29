return {
    recent_interval = 900,
    fonts = {
        header = {
            font = 'Highwind',
            size = 14,
            color = { alpha = 255, red = 255, green = 255, blue = 255 },
            stroke = { alpha = 255, red = 0, green = 0, blue = 0, width = 3 },
            bg = { alpha = 0, red = 0, green = 0, blue = 0, visible = false }
        },
        body = {
            font = 'Consolas',
            size = 10,
            color = { alpha = 255, red = 255, green = 255, blue = 255 },
            stroke = { alpha = 255, red = 0, green = 0, blue = 0, width = 3 },
            bg = { alpha = 0, red = 0, green = 0, blue = 0, visible = false }
        },
        flair = {
            font = 'Highwind',
            size = 12,
            color = { alpha = 255, red = 255, green = 255, blue = 255 },
            stroke = { alpha = 255, red = 0, green = 0, blue = 0, width = 3 },
            bg = { alpha = 0, red = 0, green = 0, blue = 0, visible = false }
        }
    },
    colors = {
        title = '218,165,32',
        divider = '100,100,100',
        active_status = '220,90,90',
        inactive_status = '100,180,130',
        session_loss = '200,120,120',
        total_loss = '200,90,90',
        recent_loss = '200,105,105'
    },
    sounds = {
        default_effect = 'cash_register_01.wav',
        enabled_by_default = true
    },
    milestones = {
        session = {
            { value = 10000,  text = '10K Session Loss!',  sound = 'cash_register_01.wav' },
            { value = 25000,  text = '25K Session Loss!',  sound = 'cash_register_01.wav' },
            { value = 50000,  text = '50K Session Loss!',  sound = 'cash_register_01.wav' },
            { value = 100000, text = '100K Session Loss!', sound = 'cash_register_02.wav' },
            { value = 150000, text = '150K Session Loss!', sound = 'cash_register_02.wav' },
            { value = 200000, text = '200K Session Loss!', sound = 'cash_register_02.wav' },
            { value = 250000, text = '250K Session Loss!', sound = 'cash_register_05.wav' },
            { value = 300000, text = '300K Session Loss!', sound = 'cash_register_05.wav' },
            { value = 350000, text = '350K Session Loss!', sound = 'cash_register_05.wav' }
        },
        total = {
            { value = 1000000,   text = '★ 1 MILLION TOTAL LOSS! ★',  sound = 'C:\\Windows\\Media\\tada.wav' },
            { value = 5000000,   text = '★ 5 MILLION TOTAL LOSS! ★',  sound = 'C:\\Windows\\Media\\tada.wav' }, -- Wait, the system message had: 5 MILLION, let's keep it consistent
            { value = 10000000,  text = '★ 10 MILLION TOTAL LOSS! ★', sound = 'C:\\Windows\\Media\\tada.wav' },
            { value = 50000000,  text = '★ 50 MILLION TOTAL LOSS! ★', sound = 'C:\\Windows\\Media\\tada.wav' },
            { value = 100000000, text = '★ 100 MILLION TOTAL LOSS! ★', sound = 'C:\\Windows\\Media\\tada.wav' }
        }
    }
}
