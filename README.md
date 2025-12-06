# MRD Explorer

## 简介

用于查看mrd文件

## 依赖

- Python >= 3.12
- PySide6 >= 6.8

## 安装与运行

```bash
# 安装依赖
uv sync

# 运行
uv run python main.py
```

## TODO

- 将归一化的范围作为交互选项（按线圈、按切片，全部）
- 将归一化的计算方式作为交互选项（是否减去最小值，除以最大值还是标准差）
- mrd文件名的解析有点耦合，想办法剥离出来
