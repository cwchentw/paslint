# paslint 🚀

A lightweight, zero-dependency Delphi / Free Pascal linter written in core Perl.

## 📌 Overview

`paslint` provides fast and lightweight static analysis for Delphi and Free Pascal source files. Built entirely using Perl's core modules, it requires no external dependencies or heavy installation processes.

## ⚡ Project Status

> ⚠️ **Development Status: Experimental / WIP**

The internal Pascal engine utilizes a **fuzzy parser** approach. It focuses on identifying key patterns and structural elements while safely skipping complex or irrelevant code blocks. This keeps the linter blazing fast and highly adaptable, though it may not fully validate strict syntax rules.

## 🛠️ System Requirements

* **Perl 5.36+** (Using core modules only; no CPAN modules required)

## 📦 Installation

Add the `paslint/bin` directory to your system `PATH`:

```bash
PATH="$PATH:/absolute/path/to/paslint/bin"
export PATH
```

## 🚀 Usage

Run the linter by passing the path to your Pascal source file:

```bash
paslint path/to/Source.pas
```

## 📄 Copyright & License

Copyright (c) 2026 ByteBard. Licensed under the **MIT License**.
