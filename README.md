# energy-trading-smart-contract

綠電交易的智能合約，有三個主要的函式如下說明

## 1. bid 投標

### 功能說明

功能：使用者投標

說明：使用者可以在單一競標時間投標多個量和單價，將根據使用者的地址儲存於智能合約內

參數：

| parameter | type | description |
| --- | --- | --- |
| `_user` | address | 使用者地址 |
| `_bid_time` | string memory | 競標時間 |
| `_bid_type` | string memory | 投標種類 |
| `_volumn` | uint256[] | 投標量 |
| `_price` | uint256[] | 投標單價 |

資料結構：

+ time => type(buy/sell) => user_address => bid_struct

+ bid_struct

    +   volumn: uint256[]
    +   price: uint256[]

### Log

| parameter | type | description | indexed |
| --- | --- | --- | --- |
| `_user` | address | 使用者地址 | n |
| `_bid_time` | string memory | 競標時間 | n |
| `_bid_type` | string memory | 投標種類 | n |
| `_volumn` | uint256[] | 投標量 | n |
| `_price` | uint256[] | 投標單價 | n |

## 2. match 媒合

### 功能說明

功能：媒合交易

說明：根據使用者的投標進行媒合

參數：

| parameter | type | description |
| --- | --- | --- |
|  |  |  |
|  |  |  |
|  |  |  |

### Log

| parameter | type | description | indexed |
| --- | --- | --- | --- |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |

## 3. settlement 結算

### 功能說明

功能：結算交易金額

說明：依據使用者上傳量計算交易金額，並進行扣款或付款的動作

參數：

| parameter | type | description |
| --- | --- | --- |
|  |  |  |
|  |  |  |
|  |  |  |

### Log

| parameter | type | description | indexed |
| --- | --- | --- | --- |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |
