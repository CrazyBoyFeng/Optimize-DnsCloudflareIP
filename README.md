# 优化 DNS Cloudflare IP
脚本：查找最快 Cloudflare IP 并更新域名解析记录。

## 如何使用
登录你的 DNS 服务提供商，添加域名解析记录。  
_请注意：目标域名的初始 IP 记录不能与其它记录重复。_

### Windows
1. 下载脚本启动器 `Optimize-DnsCloudflareIP.Cmd` 和脚本 `Optimize-DnsCloudflareIP.PS1` 至 `CloudflareST.Exe` 所在文件夹。  
2. 修改 `Optimize-DnsCloudflareIP.PS1`，按要求填写参数。
3. 执行 `Optimize-DnsCloudflareIP.Cmd`。默认常规窗口模式。结束后暂停。可通过参数调整启动器：
* `Optimize-DnsCloudflareIP.Cmd Minimized` 最小化窗口模式。仅错误时暂停。
* `Optimize-DnsCloudflareIP.Cmd Hidden` 隐藏窗口模式。结束后退出。可通过退出码和输出文件判断执行结果。

如需自动定时执行，请查阅任务计划相关知识。

### 其它操作系统
1. 下载所用 DNS 服务提供商对应目录内的 `optimize-dns-cloudflare-ip.bash` 至 `CloudflareST` 所在目录。  
2. 修改 `optimize-dns-cloudflare-ip.bash`，按要求填写参数。  
3. 执行 `optimize-dns-cloudflare-ip.bash`。

如需自动定时执行，请查阅 `cron` 相关知识。

## 捐赠与赞助
* [支付宝](https://user-images.githubusercontent.com/1733254/110204402-bbcabc80-7ead-11eb-8bbc-9be2041214c2.png)
* [微信支付](https://user-images.githubusercontent.com/1733254/110204405-bd948000-7ead-11eb-9c8a-13094e252d7a.png)

付款代表您同意就捐赠与赞助事项与我[约定](https://gist.github.com/CrazyBoyFeng/a53994e5cfb129110c150fb6ea802a87#file-donationandsponsorshipagreement-md)。
