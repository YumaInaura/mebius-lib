
#-----------------------------------------------------------
# �f���̃��[���\��
#-----------------------------------------------------------

sub bbs_rule_view{

# �錾
my($rule_text,$zatudann_text);
our($mode,$moto,$server_domain,$device_type,$divide_url,$now_url,$sub_title,$head_link3,$css_text);

# �A�N�Z�X�U�蕪��
if($mode eq "rule"){
$divide_url = "http://$server_domain/_$moto/krule.html";
if($device_type eq "mobile"){ &divide($divide_url,"mobile"); }
}
elsif($mode eq "krule"){
$divide_url = "http://$server_domain/_$moto/rule.html";
if($device_type eq "desktop"){ &divide($divide_url,"desktop"); }
}

# �g�є�
if($mode eq "krule"){ &kget_items(); }

# �^�C�g����`
if($mode eq "rule"){ $sub_title = "$title�̃��[��"; }
else{ $sub_title = "$title�̃��[�� | �g�є�"; }
$now_url ="_$moto/rule.html";
$head_link3 = "&gt; ���[��";

# ���[�h����
require "${int_dir}def_modetext.pl";
($rule_text,$zatudann_text,$none,$none,$pefrule_text) = &bbs_def_mode();


# CSS��`
$css_text .= qq(
.rulebox{color:#222;padding:0.75em 1.5em;font-weight:bold;}
.ruleplus{border:dotted 2px #f00;padding:1em 1.25em;line-height:1.5em;}
div.text{line-height:2.3em;}
li{text-decoration:underline;line-height:2.0em;}
);

# ���[���\�����`
$rule_text .= $pefrule_text;

# �w�b�_
&header();

print qq(
<div class="body1">
<h1>$title�̃��[��</h1>
<div class="text">$rule_text</div>
</div>
);

&footer();

}





1;
