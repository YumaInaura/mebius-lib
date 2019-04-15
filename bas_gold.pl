
# �p�b�P�[�W�錾
package Mebius::Goldcenter;
use strict;

# -------------------------------------------
# ��{�ݒ�
# -------------------------------------------
sub init_start_gold{

# �S�ϐ������Z�b�g
reset 'a-z';

# �錾
my($script_mode,$gold_url,$title) = &init();

# ���C���ݒ�
$main::head_link1 = 0;
$main::head_link1 = qq(&gt; <a href="http://$main::server_domain/">$main::server_domain</a> );

# �^�C�g���ݒ�
$main::sub_title = qq($title);
$main::head_link2 = qq(&gt; <a href="$gold_url">���݃Z���^�[</a> );

# CSS��`
$main::css_text .= qq(
h1{color:#220;}
h2{color:#220;background:#ee8;border:solid 1px #cc0;padding:0.35em 0.7em;font-size:100%;}
h3{color:#220;font-size:95%;background:#ffc;border:solid 1px #990;width:30%;padding:0.2em 0.5em;}
ul{margin:0.8em 0em;}
);

# CSS��` ( ���݂��g���Ȃ��ꍇ )
	if(!$main::callsave_flag){
$main::css_text .= qq(h2,h3{background:#eee;border:solid 1px #999;});
	}

# �����{�b�N�X�Ŏ������������Ȃ�
$main::nosearch_mode = 1;

# �O��CSS
$main::style = "/style/orange.css";



}

#-----------------------------------------------------------
# �p�b�P�[�W�̊�{�ݒ�
#-----------------------------------------------------------
sub init{

# �ݒ�
my $script_mode = "";	# "TEST" �Ńe�X�g���[�h
my $gold_url = "/_gold/";	# ���݃Z���^�[��URL
my $title = "���݃Z���^�[";	# �^�C�g��

# �e�X�g���[�h�̐���
if($main::myadmin_flag >= 5 || $main::alocal_mode){ $script_mode = ""; } # "TEST"

# ���^�[��
return($script_mode,$gold_url,$title);

}

#-----------------------------------------------------------
# �K�v�ȋ��ݗʂ̐ݒ�
#-----------------------------------------------------------
sub get_price{

# �錾
my($script_mode,$gold_url,$title) = &init();
my(%price);

# �e�T�[�r�X�ɕK�v�ȋ��݂��`
%price = (
"cancel_newwait" => 100, # �V�K�҂����Ԃ��Ȃ���
);

# ���^�[��
return(%price);

}

#-------------------------------------------------
# �X�^�[�g - �X�N���v�g
#-------------------------------------------------
sub start_gold{

# �錾
my($script_mode,$gold_url,$title) = &init();

	# �g�є�
	if($main::device_type eq "mobile"){
		main::kget_items();
	}

	# �����[�h�U�蕪��
	if($main::submode1 eq ""){ &index(); }

	# �V�K���e�̑҂����Ԃ𖳂���
	elsif($main::submode1 eq "cancel_newwait"){ &cancel_newwait(); }

	# �q������
	elsif($main::submode1 eq "gyamble1" && $main::postflag){ &gyamble1("",$main::in{'chaise_gold'}); }
	elsif($main::submode1 eq "gyamble1" && !$main::postflag){ &form_gyamble1("Indexview Winlose-get Page-me",$main::in{'chaise_gold'}); }

	# ���̃��[�U�[�ɋ��݂�n��
	elsif($main::submode1 eq "present_gold"){
			
		# �Ǘ��҂Ƃ��ċ��݂����^
		if($main::myadmin_flag >= 1 && $main::in{'gave_gold'}){
		&present_gold("GAVE",$main::in{'account'},$main::in{'present_gold'});
		}
		# ���[�U�[�Ƃ��ċ��݂��v���[���g
		else{
		&present_gold("PRESENT",$main::in{'account'},$main::in{'present_gold'});
		}
	}

	# �A�C�e���V���b�v
	elsif($main::submode1 eq "item"){ &item(); }
	
	# ���[�h��`���Ȃ��ꍇ
	else{ main::error("�y�[�W�����݂��܂���B"); }

exit;

}

#-----------------------------------------------------------
# �C���f�b�N�X
#-----------------------------------------------------------
sub index{

# �錾
my($script_mode,$gold_url,$title) = &init();
my(%price) = &get_price();
my($line_guide,$line_record_spend,$form_cancel_newwait,$form_present_gold,$form_gyamble1);
my($navi_links);

# CSS��`
$main::css_text .= qq(
div.guide{line-height:1.4em;}
div.index_flow{text-align:right;}
div.navilinks{word-spacing:0.5em;}
);


# ����
$line_guide = qq(<li>�A�J�E���g�Ƀ��O�C�����Ă�����A�ꕔ�̌g�ѓd�b�ł́A���݃Z���^�[�����p�ł��܂��B</li>);
	if($main::callsave_flag){ $line_guide .= qq(<li>���܂̂��Ȃ��́A���݃Z���^�[��<strong class="red">���p�ł��܂��B</strong></li>); }
	else{ $line_guide .= qq(<li>���܂̂��Ȃ��́A���݃Z���^�[��<strong class="red">���p�ł��܂���B</strong><a href="$main::auth_url?backurl=$main::selfurl_enc">�A�J�E���g</a>�Ƀ��O�C��(�܂��͐V�K�o�^)���Ă��������B</li>); }
	if($main::callsave_flag){
$line_guide .= qq(<li>���݂̓T�[�o�[���ƂɋL�^����܂��B���܂̃T�[�o�[�� $main::server_domain �ł��B</li>);
	}
$line_guide .= qq(<li class="red">���ӁI�@�T�C�g���ł̃��[���ᔽ�i�������҂��A�����̗���A���f�]�ڂȂǁj���������ꍇ�A<strong>�u���݂̏����v�u���e�����v�Ȃǂ̃y�i���e�B�����������Ă��������ꍇ������܂��B</strong></li>);

# �����̐��`
$line_guide = qq(
<h2>����</h2>
<div class="guide">
<ul>$line_guide</ul>
</div>
);


# �e��t�H�[�����擾
($form_cancel_newwait) = &form_cancel_newwait();
($form_gyamble1) = &form_gyamble1();
($form_present_gold) = &form_present_gold();

# ���݂̎g�p�L�^���Q�b�g�A���`
	if($main::in{'viewmax'}){ ($line_record_spend) = &record_spend("VIEW",""); }
	else{ ($line_record_spend) = &record_spend("VIEW","",5); }
	if($line_record_spend){
		if($main::in{'viewmax'}){ $line_record_spend = qq(<h2 id="SPEND_RECORD">���݂̎g�p�L�^</h2>\n$line_record_spend); }
		else{
$line_record_spend = qq(<h2 id="SPEND_RECORD"><a href="./?viewmax=1$main::backurl_query_enc#SPEND_RECORD">���݂̎g�p�L�^</a></h2>\n$line_record_spend);
$line_record_spend .= qq(<div class="index_flow"><a href="./?viewmax=1$main::backurl_query_enc#SPEND_RECORD">��������\\������</a></div>);
		}
	}

# �^�C�g����`
$main::head_link2 = qq( &gt; $title);
$main::canonical = $gold_url;


# �h���C�������N���擾
my($domain_links) = Mebius::Domainlinks("",$main::server_domain,"_gold/");

# �i�r�Q�[�V���������N���`
	if(!$main::kflag){
my($backurl_link) = ($main::backurl_link) if($main::backurl !~ /$gold_url/);
$navi_links = qq(
<div class="navilinks">
<a href="/">TOP�y�[�W</a> $backurl_link 
���Ȃ��̋��݁F<strong class="red">$main::cgold��</strong> <img src="/pct/icon/gold1.gif" alt="����"$main::xclose>
</div>
);
	}

# HTML
my $print = qq(
<h1>$title / $domain_links</h1>
$navi_links

$line_guide
<h2 id="SPEND_GOLD">���݂��g��</h2>
$form_present_gold
$form_gyamble1
$form_cancel_newwait
<h3>���X�҂����Ԃ̗D��</h3>
���݂�<strong class="red">�v���X</strong>���ƁA���X���e�̃`���[�W���Ԃ��Z�߂ɂȂ�܂��B<br$main::xclose>
�t��<strong class="blue">������x�}�C�i�X</strong>���ƁA�`���[�W���Ԃ����߂ɂȂ�܂��B�i�������f�j
$line_record_spend
<h2>���݃����L���O</h2>
<a href="${main::main_url}rankgold-p-1.html">�����݃����L���O�͂�����ł��B</a>
);

Mebius::Template::gzip_and_print_all({},$print);


exit;

}


#-----------------------------------------------------------
# ���݂̎g�p�L�^���擾 / �X�V
#-----------------------------------------------------------
sub record_spend{

# �錾
my($script_mode,$gold_url,$title) = &init();
my($type,$message,$maxview_line) = @_;
my(@line,$file,$viewline,$i,$newhandle);
my($maxrecord_line) = (100);

# ID���擾
my($encid) = main::id();

# �t�@�C�����`
$file = "${main::int_dir}_backup/gold_spend.log";

# �L�^����M��
	if($type =~ /RENEW/){
$newhandle = $main::chandle;
		if($newhandle eq ""){ $newhandle = $main::pmname; }
		if($newhandle eq ""){ $newhandle = qq(������); }
	}

# �ǉ�����s
	if($type =~ /RENEW/){
push(@line,"1<>$newhandle<>$message<>$main::pmfile<>$main::host<>$main::agent<>$main::date<>$main::time<>$main::cnumber<>$encid<>\n");
	}

# �t�@�C�����J��
open(GOLD_RECORD_IN,"<$file");
	if($type =~ /RENEW/){ flock(GOLD_RECORD_IN,1); }
while(<GOLD_RECORD_IN>){
chomp;
my($key2,$handle2,$message2,$account2,$host2,$agent2,$date2,$time2,$cnumber2,$encid2) = split(/<>/);
$i++;
	if($i > $maxrecord_line){ next; }
	if($type =~ /RENEW/){ push(@line,"$_\n"); }
	if($type =~ /VIEW/ && ($i <= $maxview_line || !$maxview_line)){
		if($account2){ $handle2 = qq(<a href="${main::auth_url}$account2/">$handle2 - $account2</a>); }
	$viewline .= qq(<li>$handle2 <i>��$encid2</i>�@���� $message2 ( $date2 )</li>\n);
	}
}
close(GOLD_RECORD_IN);

# �{���݂̂̏ꍇ�A���^�[��
	if($type =~ /VIEW/){
		if($viewline){ $viewline = qq(<ul>$viewline</ul>); }
return($viewline);
	}

# �t�@�C�����X�V����
	if($type =~ /RENEW/){ Mebius::Fileout("",$file,@line); }

# ���^�[��
return();

}

#-----------------------------------------------------------
# ���݂��v�Z
#-----------------------------------------------------------
sub cash_check{

# �錾
my($script_mode,$gold_url,$title) = &init();
my($type,$price) = @_;
my($line,$disabled);

	# �l�i����̏ꍇ
	if($type =~ /REGIST/){
		if($price eq ""){ main::error("�l�i���J���ł��B"); }
		if($price =~ /\D/){ main::error("���p�����̂ݎw��ł��܂��B"); }
	}

# �A�N�Z�X����
if($type =~ /REGIST/){ main::axscheck("ACCOUNT"); }

# ���\�b�h����
if(!$main::postflag && $type =~ /REGIST/){ main::error("GET���M�͏o���܂���B"); }

# �l�i�̌v�Z
	if($main::cgold < $price){
		if($type =~ /REGIST/){
main::error("���݂�����Ȃ����߁A���s�ł��܂���B $main::cgold�� / $price��");
		}
		else{
$line = qq(<span class="alert">���݂�����܂���B</span>);
$disabled = $main::parts{'disabled'};
		}
	}

# ���s�ł��Ȃ���
	if(!$main::callsave_flag){
		if($type =~ /REGIST/){
main::error("���̊��ł͎��s�ł��܂���B�A�J�E���g�Ƀ��O�C�����Ă��������B");

		}
		else{
$line = qq(<span class="alert">���̊��ł͎��s�ł��܂���B</span>);
$disabled = $main::parts{'disabled'};
		}
	}


# ���^�[��
return($line,$disabled);

}

#-----------------------------------------------------------
# �L�^�p�̕M�����擾
#-----------------------------------------------------------
sub get_handle{

# �錾
my($type) = @_;
my($handle);

# �L�^����M�����`
$handle = $main::chandle;
if($handle eq ""){ $handle = $main::pmname; }
if($handle eq ""){ $handle = qq(������); }
if($main::pmfile){ $handle = qq(<a href="${main::auth_url}$main::pmfile/">$handle</a>); }

# ���^�[��
return($handle);

}

1;
