
package main;

#-----------------------------------------------------------
# 任意のレス番にジャンプ - strict
#-----------------------------------------------------------
sub bbs_number_jump{

# 局所化
my($number,$number2,$i,$no,$move);
our(%in);

# 記事番処理 
$no = $in{'no'};
if($no eq ""){ &error("記事番を指定してください。"); }

# レス番処理
$number = $in{'No'};

# 全角数字を半角数字に置換え
$number =~ s/１/1/g;
$number =~ s/２/2/g;
$number =~ s/３/3/g;
$number =~ s/４/4/g;
$number =~ s/５/5/g;
$number =~ s/６/6/g;
$number =~ s/７/7/g;
$number =~ s/８/8/g;
$number =~ s/９/9/g;
$number =~ s/０/0/g;

$number =~ s/\Qー\E/-/g;
$number =~ s/\Q－\E/-/g;
$number =~ s/\Q＾\E/-/g;
$number =~ s/\Q^\E/-/g;

$number =~ s/no\./,/ig;

$number =~ s/( |\/|\.|\:|\;|\\)/,/g;
$number =~ s/(　|￥|，|、|。|，|．|・|：|；)/,/g;

# 無関係な文字列を消去
$number =~ s/([^0-9,\-])//g;

# シャープ番号処理
#($move) = split(/,/,$number);
#($move) = split(/-/,$move);

# レス番がない場合
if($number eq ""){ &error("レス番を指定してください。"); }
unless($number =~ /\w/){ &error("レス番を指定してください。"); }

	# 展開して、変な表記を修正
	foreach(split(/,/,$number)){
		if($_ ne ""){
				if($i){ $number2 .= ","; }
			$number2 .= $_;
			$i++;
		} 
	}

# リダイレクト
Mebius::Redirect("","$no.html-$number2#a");

}


1;

