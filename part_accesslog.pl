package main;

#-----------------------------------------------------------
# アクセスログの記録
#-----------------------------------------------------------
sub do_access_log{

# 局所化
my($input,$comment,$unlink_rand) = @_;
my($logname,$type) = split(/ /,$input);
my($init_directory) = Mebius::BaseInitDirectory();
our($date);



my($file,$line,$view_host);
my $logpms = 0606;

# 汚染チェック
$logname =~ s/[^\w-]//g;
if($logname eq ""){ return; }

# 環境変数を取得
my $s1 = $ENV{'FORWARDED_FOR'};			#	squidなどのCacheサーバーを使ってる場合に…
my $s2 = $ENV{'HTTP_CACHE_CONTROL'};		#	キャッシュする最長時間など
my $s1 = $ENV{'HTTP_CACHE_INFO'};		#	キャッシュの情報
my $client_addr = $ENV{'HTTP_CLIENT_IP'};	#	接続元のIPアドレス
my $s1 = $ENV{'HTTP_CONNECTION'};		#keep-alive;	接続の状態
my $s1 = $ENV{'HTTP_FORWARDED'};			#	プロキシまたはクライアントの場所
my $s1 = $ENV{'HTTP_PRAGMA'};			#	プロキシのキャッシュに関する動作方式
my $s1 = $ENV{'HTTP_PROXY_CONNECTION'};	#	プロキシの接続形態
my $sp_host = $ENV{'HTTP_SP_HOST'};		#	接続元のIPアドレス
my $s1 = $ENV{'HTTP_TE'};			#	プロキシ等がサポートするTransfer-Encodings
my $s1 = $ENV{'HTTP_VIA'};			#	プロキシの情報（プロキシの種類，バージョン等）
my $s1 = $ENV{'PROXY_CONNECTION'};		#	プロキシの効果などを表示
my $s1 = $ENV{'HTTP_X_FORWARDED_FOR'};		#
my $addr = $ENV{'REMOTE_ADDR'};
my $agent = $ENV{'HTTP_USER_AGENT'};
my $host2 = $ENV{'REMOTE_HOST'};
my $requri = $ENV{'REQUEST_URI'};
$view_host = $host;

# 書き込み内容を定義
$line .= qq($time	$date	$view_host	$addr $cliend_addr $sp_host	$moto $requri	$postbuf \n);
$line .= qq($agent $ENV{'HTTP_X_UP_SUBNO'} $ENV{'HTTP_X_EM_UID'}\n);
	if($cookie){
		my($cookie_dec) = Mebius::Decode("",$cookie);
		$line .= qq($cookie_dec\n);
	}
if($referer){ $line .= qq(Referer: $referer\n); }
if($comment){ $line .= qq($comment\n); }
$line .= qq(\n);


# ファイル定義
$file = "${init_directory}_accesslog/${logname}_accesslog.log";

# ファイルを更新
open(ACCESSLOG_OUT,">>$file");
print ACCESSLOG_OUT $line;
close(ACCESSLOG_OUT);
Mebius::Chmod(undef,"$file");

# 一定確率でファイルを削除
if(!$unlink_rand){ $unlink_rand = 500; } 
if(rand($unlink_rand) < 1){ unlink("$file"); }

}

1;
