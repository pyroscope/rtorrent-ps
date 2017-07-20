User's Manual
=============

This chapter describes the additional features in *rTorrent-PS*,
and other differences to a vanilla *rTorrent* build.


.. _features-std-cfg:

Additional Features
-------------------

If you followed the instructions in the `Extending your ‘.rtorrent.rc’`_
section of the ``pyrocore`` manual, you will get the following
additional features in your ``rTorrent-PS`` installation:

#.  the ``t`` key is bound to a ``trackers`` view that shows all items
    sorted by tracker and then by name.
#.  the ``!`` key is bound to a ``messages`` view, listing all items
    that currently have a non-empty message, sorted in order of the
    message text.
#.  the ``^`` key is bound to the ``rtcontrol`` search result view, so
    you can easily return to your last search.
#.  the ``?`` key is bound to the ``indemand`` view, which sorts all
    open items by their activity, with the most recently active on top.
#.  ``Page ↑`` and ``Page ↓`` scroll by 50 items at a time (or whatever
    other value ``ui.focus.page_size`` has).
#.  ``Home`` / ``End`` jump to the first / last item in the current
    view.
#.  the ``~`` key rotates through all available color themes, or a
    user-selected subset.
#.  the ``<`` and ``>`` keys rotate through all added category views
    (``pyro.category.add=‹name›``), with filtering based on the
    ruTorrent label (``custom_1=‹name›``).
#.  ``|`` reapplies the category filter and thus updates the current
    category view.
#.  the ``u`` key shows the uptime and some other essential data of your
    rTorrent instance.
#.  ``F2`` shows some important help resources (web links) in the
    console log.
#.  ``*`` toggles between the collapsed (as described on `Extended
    Canvas Explained`_) and the expanded display of the current view.
    |rt-ps-name-view|
#.  The ``active`` view is changed to include all incomplete items
    regardless of whether they have any traffic, and then groups the
    list into complete, incomplete, and queued items, in that order.
    Within each group, they're sorted by download and then upload speed.
#.  The commands ``s=«keyword»``, ``t=«tracker_alias»``, and
    ``f=«filter_condition»`` are pre-defined for searching using a
    Ctrl-X prompt.
#.  The ``.`` key toggles the membership in the ``tagged`` view for the
    item in focus, ``:`` shows the ``tagged`` view, and ``T`` clears
    that view (i.e. removes the tagged state on all items). This can be
    very useful to manually select a few items and then run
    ``rtcontrol`` on them, or alternatively use ``--to-view tagged`` to
    populate the ``tagged`` view, then deselect some items interactively
    with the ``.`` key, and finally mass-control the rest.
#.  You can use the ``purge=`` and ``cull=`` commands (on a Ctrl-X
    prompt) for deleting the current item and its (incomplete) data.
#.  ``Ctrl-g`` shows the tags of an item (as managed by ``rtcontrol``);
    ``tag.add=‹tag›`` and ``tag.rm=‹tag›`` can be used to change the set
    of tags, both also show the new set of tags after changing them.
#.  Trackers are scraped regularly (active items relatively often,
    inactive items including closed ones seldomly), so that the display
    of downloads / seeders / leechers is not totally outdated.

.. _Extending your ‘.rtorrent.rc’: https://pyrocore.readthedocs.org/en/latest/setup.html#extending-your-rtorrent-rc

.. |rt-ps-name-view| image:: _static/img/rt-ps-name-view.png


.. _extended-canvas:

Extended Canvas Explained
-------------------------
