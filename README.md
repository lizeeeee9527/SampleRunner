# SampleRunner

A rather simple plugin to run your cpp/python code with specifical sample in neovim, especial fit with begginer

## 📺 display

![Show](https://github.com/lizeeeee9527/SampleRunner.nvim/blob/main/Display/show.gif)

## ✨ Features

- Fast compilation and execution with visual input/output display

- Save your sample so that no need to retype  it

- Independent  and clear input and output showcase

## 📦 Installation (for LazyVim)

For Lazyvim users:
```lua
return {
  "lizeeeee9527/SampleRunner",
  config = function()
    require("SampleRunner").setup()
  end,
}
```

## 🚀 Usage

- `<leader>` li: show the input ans output windows
- `<leader>` lc: close the input ans output windows
- `<leader>` ls: run your code

- or for commands:
  - LayoutInitiate
  - LayoutClose
  - RunSample

## ⏳ Future plans

1. create a changeable input system
2. more language
3. more windows styles

but for now, it's enough... Maybe its the ultimate version...☺️

## ✉️ Other talk

I'm new to nvim and there're many things I cnanot solve, so I admit that it is almost produced by ai.

But this plugins are quite simple and work well for myself, or maybe for you, so it's a nice try, I think.


