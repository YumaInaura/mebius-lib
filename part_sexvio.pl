
package main;


#-----------------------------------------------------------
# 性表現、暴力表現の閲覧
#-----------------------------------------------------------

sub sexvio_check{

my($key) = @_;
my($age);
my($basic_init) = Mebius::basic_init();
my($free);
our $sexvio_text = "";

	# Cookieの使えない携帯へのアクセス許可
	if($k_access && !$cookie){ $free = 1; }
	# Botへのアクセス許可
	if($main::device{'bot_flag'}){ $free = 1; }

# CSS定義
$css_text .= qq(.svio_alert{color:#f00;font-size:120%;});

	# 現在の年齢を計算
	if($free || Mebius::Admin::admin_mode_judge()){ $age = 20; }
	elsif(!$cage){ $age = 0; }
	else{ $age = $thisyear - $cage; }

	# 性表現＆暴力表現
	if($key eq "3"){
		if(!$age){ &error("この記事には「性的な内容」「ショッキングな内容が含まれます。18才以上の方は<a href=\"$basic_init->{'main_url'}?mode=settings#EDIT\">マイページ</a>で年齢設定をすることで閲覧できます。","401 Unauthorized"); }
		elsif($age < 18){ &error("この記事には「性的な内容」「ショッキングな内容」が含まれるため、18才未満の方は閲覧できません。","401 Unauthorized"); }
		else{ $sexvio_text = qq(この記事には「性的な内容」「ショッキングな内容」が含まれます。); }
	}

	# 性表現
	if($key eq "2"){
		if(!$age){ &error("この記事には性的な内容が含まれます。18才以上の方は<a href=\"$basic_init->{'main_url'}?mode=settings#EDIT\">マイページ</a>で年齢設定をすることで閲覧できます。","401 Unauthorized"); }
		elsif($age < 18){ &error("この記事には性的な内容が含まれるため、18才未満の方は閲覧できません。","401 Unauthorized"); }
		else{ $sexvio_text = qq(この記事には性的な内容が含まれます。); }
	}

	# 暴力表現
	if($key eq "1"){
		
		if(!$age){ &error("この記事にはショッキングな内容が含まれます。15才以上の方は<a href=\"$basic_init->{'main_url'}?mode=settings#EDIT\">マイページ</a>で年齢設定をすることで閲覧できます。","401 Unauthorized"); }
		elsif($age < 15){ &error("この記事にはショッキングな内容が含まれるため、15才未満の方は閲覧できません。","401 Unauthorized"); }
		else{ $sexvio_text = qq(この記事にはショッキングな内容が含まれます。); }
	}

	# テキスト整形
	if($sexvio_text){
			# 携帯版
			if($kflag){ $sexvio_text = qq(★$sexvio_textもし記事に問題がある場合は<a href="http://aurasoul.mb2.jp/_delete/">削除依頼掲示板</a>までお知らせください。<br$xclose>); }
			# PC版
			else{ $sexvio_text = qq(<em class="svio_alert">★$sexvio_textもし記事に問題がある場合は違反報告してください。</em><br$xclose><br$xclose>); }
	}

# 広告を消す
$noads_mode = 1;

my $return = $sexvio_text;

$return;

}

#-----------------------------------------------------------
# 性表現、暴力表現の入力チェック
#-----------------------------------------------------------

sub sexvio_form{

# 局所化
my($age,$checked1,$checked2,$kbr1);
my($basic_init) = Mebius::basic_init();

# 携帯でクッキー認証できない場合
my($free);
if($k_access && !$cookie){ $free = 1; }


# 現在の年齢を計算
if($free){ $age = 20; }
elsif(!$cage){ $age = 0; }
else{ $age = $thisyear - $cage; }

# プレビューのチェックを入れる
if($in{'vio'}){ $checked1 = $checked; }
if($in{'sex'}){ $checked2 = $checked; }

# 携帯用整形
if($kflag){ $kbr1 = qq(<br$xclose>); }
	# ショッキングな内容
	if($main::bbs{'concept'} =~ /Sousaku-mode/ && $category ne "diary"){
	if(!$age){ $viocheck = qq(<br$xclose><input type="checkbox" name="vio" value=""$disabled$xclose> ショッキングな内容 - 暴\力・イジメ・リストカットなど - を含む場合は、<a href="$basic_init->{'main_url'}?mode=settings#EDIT">マイページ</a>で年齢設定を済ませてください（15才以上）。); }
	elsif($age < 15){  $viocheck = qq(<br$xclose><input type="checkbox" name="vio" value=""$disabled$xclose> 15才未満の方は「ショッキングな表\現」のチェックを入れられません。); }
	else{ $viocheck = qq(<br$xclose><input type="checkbox" name="vio" value="1" $checked1$xclose> この記事には、ショッキングな内容が含まれます（15才未満の方には非公開になります）。); }
	}
	else{
	if($age >= 15){ $viocheck = qq(<br$xclose><input type="checkbox" name="vio" value="1" $checked1$xclose> この記事には、ショッキングな相談・議論が含まれるので、15才未満の方には非公開にします（任意）。); }
	}

	# 性的な内容
	if($main::bbs{'concept'} =~ /Sousaku-mode/){
	if(!$age){ $sexcheck = qq(<br$xclose><input type="checkbox" name="sex" value=""$disabled$xclose> 性的な内容を含む場合は、<a href="$basic_init->{'main_url'}?mode=settings#EDIT">マイページ</a>で年齢設定を済ませてください（18才以上）。$kbr1); }
	elsif($age < 18){  $sexcheck = qq(<br$xclose><input type="checkbox" name="sex" value=""$disabled$xclose> 18才未満の方は「性的な表\現のチェック」を使えません。$kbr1); }
	else{ $sexcheck = qq(<br$xclose><input type="checkbox" name="sex" value="1" $checked2$xclose> この記事には、性的な内容が含まれます（18才未満の方には非公開になります）。$kbr1); }
	}
	else{
	if($age >= 18){ $sexcheck = qq(<br$xclose><input type="checkbox" name="sex" value="1" $checked2$xclose> この記事には、性的な相談・議論が含まれるので、18才未満の方には非公開にします（任意）。$kbr1); }
	}



# PC版整形
if(!$kflag){
$sexcheck = qq(<span class="sexvio">$sexcheck</span>);
$viocheck = qq(<span class="sexvio">$viocheck</span>);
}

}


1;
