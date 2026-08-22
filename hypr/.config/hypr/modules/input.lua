-- Input configuration --

hl.config({
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        sensitivity = 0,

        repeat_rate = 50,
        repeat_delay = 250,

        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
            disable_while_typing = true,
            clickfinger_behavior = true,
        },
    },

    cursor = {
        -- Ẩn con trỏ sau 10s không đụng chuột — đỡ vướng mắt khi gõ phím
        inactive_timeout = 10,
    },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
