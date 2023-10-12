## Convert HK Go Record

for [ranks](https://github.com/horaceho/ranks)

### 安裝 Install ruby [for macOS](https://www.ruby-lang.org/en/documentation/installation/#homebrew)
```bash
brew install ruby
```

### 安裝 Install gems
```bash
gem install optparse
gem install roo
```

### 用法 Usage
```bash
ruby ./hkgo.rb
Usage: ruby hogo.rb [options] {file}
        --player                     Output players data
        --record                     Output game records
```

### 測試 Test
```bash
mkdir -p test
cp ./data/HKGODB_game_record_2018_2023_open.xlsx ./test/

ruby ./hkgo.rb --player data/HKGODB_game_record_2018_2023_open.xlsx > test/HKGODB-2018-2023-open-player.csv
ruby ./hkgo.rb --record data/HKGODB_game_record_2018_2023_open.xlsx > test/HKGODB-2018-2023-open-record.csv
```

### 嗚謝 Acknowledgement

- Thomas Lau 提供數據及建議 for data and guidance.

&copy; 2023 [Horace Ho](https://horaceho.com)
