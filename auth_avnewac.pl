
use strict;
use Mebius::AuthAccount;
#package main;

#-----------------------------------------------------------
# SNS �A�J�E���g�ꗗ
#-----------------------------------------------------------
sub auth_avnewac{

# �Ǐ���
my(%account_list);
our($body_javascript,$css_text,%in,$title,$head_link2,$head_link3,$action,$submode3,$sub_title,$footer_link,$footer_link2);

# �e��G���[
if($submode3 eq ""){ &error("�y�[�W�����݂��܂���B"); }

# CSS��`
$css_text .= qq(
span.guide{font-size:90%;color:#080;}
);

	
	# ���[�h��������ꍇ
	if($main::in{'word'}){

		# �L�[���[�h����
		my $keyword = $main::in{'word'};
		$keyword =~ s/(${main::auth_url}|\/|_)//g;

		(%account_list) = Mebius::Auth::AccountListFile("Get-index Keyword-search-mode Search-file",$keyword);
	}
	# ���[�h�������Ȃ��ꍇ
	else{
		(%account_list) = Mebius::Auth::AccountListFile("Get-index Normal-file");
	}




# �^�C�g����`
$sub_title =  "�A�J�E���g�ꗗ - $title";
$head_link2 = " &gt; �A�J�E���g�ꗗ";
	if($in{'word'} ne ""){
		$sub_title = "�h$in{'word'}�h�Ō��� - �A�J�E���g�ꗗ - $title";
		$head_link2 = qq(&gt; <a href="./aview-newac-1.html">�A�J�E���g�ꗗ</a> );
		$head_link3 = qq(&gt; �h$in{'word'}�h�Ō��� );
	}

	# �t�H�[�J�X�𓖂Ă�
	if(!exists $main::in{'word'}){
		$body_javascript = qq( onload="document.member.word.focus()");
	}


# �����t�H�[��
my $form = qq(
<h2>�����o�[����</h2>
<form action="$action" name="member">
<div>
<input type="text" name="word" value="$in{'word'}">
<input type="hidden" name="mode" value="aview-newac-1">
<input type="submit" value="��������">�@
<span class="guide">*�M���A�A�J�E���g�����猟�����܂��B</span>
</div>
</form>
);

if($in{'word'} ne ""){ $form .= qq(<br><a href="aview-newac-1.html">�����ʂɕ\\��</a>); }


my $print = <<"EOM";
$footer_link
<h1>�A�J�E���g�ꗗ</h1>
$form
<h2>�ꗗ</h2>
<ul>
$account_list{'index_line'}
</ul><br>
$footer_link2
EOM

Mebius::Template::gzip_and_print_all({},$print);


exit;

}

1;
