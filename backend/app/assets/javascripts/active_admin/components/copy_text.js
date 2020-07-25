$(function() {  
    $('.row-mysql_password td, .row-wordpress_password td').each(function(){
        $(this).attr('title', "可复制");
        $(this).click(function(){
            $('.row td.active').removeClass('active');
            $(this).addClass('active'); 
            var tempInput = document.createElement("input");
            tempInput.value = $(this).text();
            document.body.appendChild(tempInput);
            tempInput.select();
            tempInput.setSelectionRange(0, 99999);
            document.execCommand("copy");
            document.body.removeChild(tempInput);   
        })
    })
})