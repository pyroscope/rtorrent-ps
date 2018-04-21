$(document).ready(function(){
    $('dt[id]').each(function() {
        $('<a class="headerlink">\u00B6</a>').
            attr('href', '#' + this.id).
            attr('title', _('Permalink to this definition')).
            appendTo(this);
    });
});
