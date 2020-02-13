### Copyright (C) 2005-2007 Gustavo J. A. M. Carneiro
###
### This library is free software; you can redistribute it and/or
### modify it under the terms of the GNU Lesser General Public
### License as published by the Free Software Foundation; either
### version 2 of the License, or (at your option) any later version.
###
### This library is distributed in the hope that it will be useful,
### but WITHOUT ANY WARRANTY; without even the implied warranty of
### MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
### Lesser General Public License for more details.
###
### You should have received a copy of the GNU Lesser General Public
### License along with this library; if not, write to the
### Free Software Foundation, Inc., 59 Temple Place - Suite 330,
### Boston, MA 02111-1307, USA.

'''
A Gtk.TextView-based renderer for XHTML-IM, as described in:
  http://www.jabber.org/jeps/jep-0071.html
'''
from gi.repository import GObject
from gi.repository import Pango
from gi.repository import Gtk
from gi.repository import Gdk
import xml.sax
import xml.sax.handler
import re
import sys
import warnings

if sys.version_info < (3,):
    from cStringIO import StringIO # pylint: disable=E0401
else:
    from io import StringIO

__all__ = ['HtmlTextView']

whitespace_rx = re.compile("\\s+")

def _parse_css_color(color):
    '''_parse_css_color(css_color) -> Gdk.Color'''
    if color.startswith("rgb(") and color.endswith(')'):
        r, g, b = [int(c)*257 for c in color[4:-1].split(',')]
        return Gdk.Color(r, g, b)
    return Gdk.color_parse(color)


# class HtmlEntityResolver(xml.sax.handler.EntityResolver):
#     def resolveEntity(publicId, systemId):
#        pass

class HtmlHandler(xml.sax.handler.ContentHandler):

    def __init__(self, textview, startiter):
        xml.sax.handler.ContentHandler.__init__(self)
        self.textbuf = textview.get_buffer()
        self.textview = textview
        self.iter = startiter
        self.text = ''
        self.styles = [] # a list of sequences of Gtk.TextTag, for each span level
        self.list_counters = [] # stack (top at head) of list
                                # counters, or None for unordered list

    def _parse_style_color(self, tag, value):
        color = _parse_css_color(value)
        tag.set_property("foreground-gdk", color)

    def _parse_style_background_color(self, tag, value):
        color = _parse_css_color(value)
        tag.set_property("background-gdk", color)
        tag.set_property("paragraph-background-gdk", color)


    def _get_current_fontsize(self):
        attrs = self.textview.get_default_attributes()
        result = attrs.font.get_size()
        for tag in self._get_style_tags():
            if tag.get_property('size-set'):
                result = tag.get_property('size')
        return result

    def _get_current_fontscale(self):
        result = 1.0
        for tag in self._get_style_tags():
            if tag.get_property('scale-set'):
                result = tag.get_property('scale')
        return result

    def __parse_length_frac_size_allocate(self, _textview, allocation,
                                          frac, callback, args):
        callback(allocation.width*frac, False, *args)

    def _parse_length(self, value, font_relative, callback, *args):
        '''Parse/calc length, converting to pixels, calls callback(length, *args)
        when the length is first computed or changes'''
        if value.endswith('%'):
            frac = float(value[:-1])/100
            if font_relative:
                font_size = self._get_current_fontsize()
                callback(frac*font_size, True, *args)
            else:
                ## CSS says "Percentage values: refer to width of the closest
                ##           block-level ancestor"
                ## This is difficult/impossible to implement, so we use
                ## textview width instead; a reasonable approximation..
                alloc = self.textview.get_allocation()
                self.__parse_length_frac_size_allocate(self.textview, alloc,
                                                       frac, callback, args)
                self.textview.connect("size-allocate",
                                      self.__parse_length_frac_size_allocate,
                                      frac, callback, args)

        elif value.endswith('pt'): # points
            callback(float(value[:-2]), False, *args)

        elif value.endswith('em'): # ems, the height of the element's font
            font_size = self._get_current_fontsize()
            callback(float(value[:-2])*font_size, True, *args)

        elif value.endswith('ex'): # x-height, ~ the height of the letter 'x'
            ## FIXME: figure out how to calculate this correctly
            ##        for now 'em' size is used as approximation
            font_size = self._get_current_fontsize()
            callback(float(value[:-2])*font_size, True, *args)

        elif value.endswith('px'): # pixels
            callback(int(value[:-2])*Pango.SCALE, True, *args)

        else:
            warnings.warn("Unable to parse length value '%s'" % value)

    @staticmethod
    def __parse_font_size_cb(length, pango_units, tag):
        if pango_units:
            tag.set_property("size", length)
        else: # points
            tag.set_property("size-points", length)

    def _parse_style_font_size(self, tag, value):
        try:
            scale = {
                "xx-small": 0.5787037037037,
                "x-small": 0.6444444444444,
                "small": 0.8333333333333,
                "medium": 1.0,
                "large": 1.2,
                "x-large": 1.4399999999999,
                "xx-large": 1.728,
                } [value]
        except KeyError:
            pass
        else:
            tag.set_property("scale", scale / self._get_current_fontscale())
            return
        if value == 'smaller':
            tag.set_property("scale", 0.8333333333333)
            return
        if value == 'larger':
            tag.set_property("scale", 1.2)
            return
        self._parse_length(value, True, self.__parse_font_size_cb, tag)

    def _parse_style_font_style(self, tag, value):
        try:
            style = {
                "normal": Pango.Style.NORMAL,
                "italic": Pango.Style.ITALIC,
                "oblique": Pango.Style.OBLIQUE,
                } [value]
        except KeyError:
            warnings.warn("unknown font-style %s" % value)
        else:
            tag.set_property("style", style)

    @staticmethod
    def __frac_length_tag_cb(length, pango_units, tag, propname):
        if pango_units:
            length = length / Pango.SCALE
        # else assume points = pixels, whatever
        tag.set_property(propname, length)

    def _parse_style_margin_left(self, tag, value):
        self._parse_length(value, False, self.__frac_length_tag_cb,
                           tag, "left-margin")

    def _parse_style_margin_right(self, tag, value):
        self._parse_length(value, False, self.__frac_length_tag_cb,
                           tag, "right-margin")

    def _parse_style_font_weight(self, tag, value):
        ## TODO: missing 'bolder' and 'lighter'
        try:
            weight = {
                '100': Pango.Weight.ULTRALIGHT,
                '200': Pango.Weight.ULTRALIGHT,
                '300': Pango.Weight.LIGHT,
                '400': Pango.Weight.NORMAL,
                '500': Pango.Weight.NORMAL,
                '600': Pango.Weight.BOLD,
                '700': Pango.Weight.BOLD,
                '800': Pango.Weight.ULTRABOLD,
                '900': Pango.Weight.HEAVY,
                'normal': Pango.Weight.NORMAL,
                'bold': Pango.Weight.BOLD,
                } [value]
        except KeyError:
            warnings.warn("unknown font-style %s" % value)
        else:
            tag.set_property("weight", weight)

    def _parse_style_font_family(self, tag, value):
        tag.set_property("family", value)

    def _parse_style_text_align(self, tag, value):
        try:
            align = {
                'left': Gtk.Justification.LEFT,
                'right': Gtk.Justification.RIGHT,
                'center': Gtk.Justification.CENTER,
                'justify': Gtk.Justification.FILL,
                } [value]
        except KeyError:
            warnings.warn("Invalid text-align:%s requested" % value)
        else:
            tag.set_property("justification", align)

    def _parse_style_text_decoration(self, tag, value):
        if value == "none":
            tag.set_property("underline", Pango.Underline.NONE)
            tag.set_property("strikethrough", False)
        elif value == "underline":
            tag.set_property("underline", Pango.Underline.SINGLE)
            tag.set_property("strikethrough", False)
        elif value == "overline":
            warnings.warn("text-decoration:overline not implemented")
            tag.set_property("underline", Pango.Underline.NONE)
            tag.set_property("strikethrough", False)
        elif value == "line-through":
            tag.set_property("underline", Pango.Underline.NONE)
            tag.set_property("strikethrough", True)
        elif value == "blink":
            warnings.warn("text-decoration:blink not implemented")
        else:
            warnings.warn("text-decoration:%s not implemented" % value)

    def _parse_style_vertical_align(self, tag, value):
        if value == 'sub':
            tag.set_property("rise", -10000 / 2)
            tag.set_property("scale", 0.8333333333333)
        elif value == 'super':
            tag.set_property("rise", 10000 / 2)
            tag.set_property("scale", 0.8333333333333)
        else:
            warnings.warn("Unsupported or invalid vertical-align:%s requested" % value)

    ## build a dictionary mapping styles to methods, for greater speed
    __style_methods = dict()
    for style in ["background-color", "color", "font-family", "font-size",
                  "font-style", "font-weight", "margin-left", "margin-right",
                  "text-align", "text-decoration", "vertical-align"]:
        try:
            method = locals()["_parse_style_%s" % style.replace('-', '_')]
        except KeyError:
            warnings.warn("Style attribute '%s' not yet implemented" % style)
        else:
            __style_methods[style] = method

    def _get_style_tags(self):
        return [tag for tags in self.styles for tag in tags]

    def _begin_span(self, style, tags=()):
        if style is None:
            self.styles.append(tags)
            return
        tags = list(tags)
        for item in style.split(';'):
            item = item.strip()
            if item == "":
                continue
            try:
                attr, val = item.split(':', 1)
            except ValueError:
                raise ValueError("the '%s' style is malformed" % item)
            attr = attr.rstrip().lower()
            val = val.lstrip()
            try:
                method = self.__style_methods[attr]
            except KeyError:
                warnings.warn("Style attribute '%s' requested "
                              "but not yet implemented" % attr)
            else:
                tag = self.textbuf.create_tag()
                tags.append(tag)
                method(self, tag, val)
        self.styles.append(tags)

    def _end_span(self):
        self.styles.pop(-1)

    def _insert_text(self, text):
        tags = self._get_style_tags()
        if tags:
            self.textbuf.insert_with_tags(self.iter, text, *tags)
        else:
            self.textbuf.insert(self.iter, text)

    def _flush_text(self):
        if not self.text:
            return
        self.text = self.text.replace('\n', ' ')
        if self.iter.starts_line():
            self.text = self.text.lstrip(' ')
        self._insert_text(self.text)
        self.text = ''

    def _anchor_event(self, _tag, _textview, event, _iter, href, type_):
        if event.type == Gdk.EventType.BUTTON_PRESS and event.button.button == 1:
            self.textview.emit("url-clicked", href, type_)
            return True
        return False

    def characters(self, content):
        self.text += whitespace_rx.sub(' ', content)

    _TAG_STYLES = {
        'b': 'font-weight: bold',
        'big': 'font-size: large',
        'cite': 'font-style: italic',
        'code': 'font-family: monospace',
        'dfn': 'font-style: italic',
        'em': 'font-style: italic',
        'i': 'font-style: italic',
        'kbd': 'font-family: monospace',
        'samp': 'font-family: monospace',
        'small': 'font-size: small',
        'strong': 'font-weight: bold',
        'sub': 'vertical-align: sub',
        'sup': 'vertical-align: super',
        'u': 'text-decoration: underline',
        'var': 'font-style: italic',
        }

    _NOP_TAGS = frozenset((
            # The above
            'b', 'big', 'cite', 'code', 'dfn', 'em', 'i', 'kbd',
            'samp', 'small', 'strong', 'sub', 'sup', 'u', 'var',
            # Some extra
            'a', 'body', 'span'))

    def startElement(self, name, attrs):
        self._flush_text()

        if 'style' in attrs:
            style = attrs['style']
        elif name in self._TAG_STYLES:
            style = self._TAG_STYLES[name]
        else:
            style = None

        tags = ()
        if name == 'a':
            anchor_tag = self.textbuf.create_tag()
            try:
                type_ = attrs['type']
            except KeyError:
                type_ = None
            anchor_tag.connect('event', self._anchor_event, attrs['href'], type_)
            anchor_tag.is_anchor = True
            tags = (self.textview.link_tag, anchor_tag)

        self._begin_span(style, tags)

        if name == 'br':
            pass # handled in endElement
        elif name == 'p':
            if not self.iter.starts_line():
                self._insert_text("\n")
        elif name == 'div':
            if not self.iter.starts_line():
                self._insert_text("\n")
        elif name == 'ul':
            if not self.iter.starts_line():
                self._insert_text("\n")
            self.list_counters.insert(0, None)
        elif name == 'ol':
            if not self.iter.starts_line():
                self._insert_text("\n")
            self.list_counters.insert(0, 0)
        elif name == 'li':
            if self.list_counters[0] is None:
                li_head = u'\u2022'
            else:
                self.list_counters[0] += 1
                li_head = "%i." % self.list_counters[0]
            self.text = ' '*len(self.list_counters)*4 + li_head + ' '
        elif name == 'img':
            try:
                # Loading arbitrary images is disabled for security reasons.
                # Apparently GdkPixbuf isn't safe for loading arbitrary images.
                # Anyway, loading from the network would block, which we
                # probably don't want.
                pixbuf = self.textview.images[attrs['src']]
            except Exception:
                pixbuf = None
                try:
                    alt = attrs['alt']
                except KeyError:
                    alt = "Broken image"
            if pixbuf is not None:
                tags = self._get_style_tags()
                if tags:
                    tmpmark = self.textbuf.create_mark(None, self.iter, True)

                self.textbuf.insert_pixbuf(self.iter, pixbuf)

                if tags:
                    start = self.textbuf.get_iter_at_mark(tmpmark)
                    for tag in tags:
                        self.textbuf.apply_tag(tag, start, self.iter)
                    self.textbuf.delete_mark(tmpmark)
            else:
                self._insert_text("[IMG: %s]" % alt)
        elif name in self._NOP_TAGS:
            pass
        else:
            warnings.warn("Unhandled element '%s'" % name)

    def endElement(self, name):
        self._flush_text()
        if name == 'p':
            if not self.iter.starts_line():
                self._insert_text("\n")
        elif name == 'div':
            if not self.iter.starts_line():
                self._insert_text("\n")
        elif name == 'br':
            self._insert_text("\n")
        elif name == 'ul':
            self.list_counters.pop()
        elif name == 'ol':
            self.list_counters.pop()
        elif name == 'li':
            self._insert_text("\n")
        elif name == 'img':
            pass
        elif name in self._NOP_TAGS:
            pass
        else:
            warnings.warn("Unhandled element '%s'" % name)
        self._end_span()


class HtmlTextView(Gtk.TextView):
    __gtype_name__ = 'HtmlTextView'
    __gsignals__ = {
        'url-clicked': (GObject.SignalFlags.RUN_LAST, None, (str, str)), # href, type
    }
    __gproperties__ = {
    'labellike' :
     (GObject.TYPE_BOOLEAN,
      "labellike",
      "Custom CodeWeavers control for label-like appearance",
      False,
      GObject.ParamFlags.READABLE | GObject.ParamFlags.WRITABLE | GObject.ParamFlags.CONSTRUCT)
    }

    def setup_transparent_background(self):
        css_provider = Gtk.CssProvider.new()
        css_provider.load_from_data(b"textview, text { background-color: transparent; }")
        self.get_style_context().add_provider(css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

    def __init__(self):
        Gtk.TextView.__init__(self)
        self.set_wrap_mode(Gtk.WrapMode.CHAR)
        self.set_editable(False)
        self._changed_cursor = False
        self.connect("motion-notify-event", self.__motion_notify_event)
        self.connect("leave-notify-event", self.__leave_event)
        self.connect("enter-notify-event", self.__motion_notify_event)
        self.connect("style-set", self.__style_set)
        self.setup_transparent_background()
        self.set_pixels_above_lines(3)
        self.set_pixels_below_lines(3)
        self.images = {} # a dictionary of strings to gdkpixbuf objects for
                         # images that are acceptable in html
        self.link_tag = self.get_buffer().create_tag()

    def __leave_event(self, widget, _event):
        if self._changed_cursor:
            window = widget.get_window(Gtk.TextWindowType.TEXT)
            window.set_cursor(Gdk.Cursor.new(Gdk.CursorType.XTERM))
            self._changed_cursor = False

    def __motion_notify_event(self, widget, event):
        _window, x, y, _mask = widget.props.window.get_device_position(event.device)
        x, y = widget.window_to_buffer_coords(Gtk.TextWindowType.TEXT, x, y)
        tags = widget.get_iter_at_location(x, y)[1].get_tags()
        for tag in tags:
            if getattr(tag, 'is_anchor', False):
                is_over_anchor = True
                break
        else:
            is_over_anchor = False
        if not self._changed_cursor and is_over_anchor:
            window = widget.get_window(Gtk.TextWindowType.TEXT)
            window.set_cursor(Gdk.Cursor.new_for_display(
                Gdk.Display.get_default(),
                Gdk.CursorType.HAND2))
            self._changed_cursor = True
        elif self._changed_cursor and not is_over_anchor:
            window = widget.get_window(Gtk.TextWindowType.TEXT)
            window.set_cursor(Gdk.Cursor.new_for_display(
                Gdk.Display.get_default(),
                Gdk.CursorType.XTERM))
            self._changed_cursor = False
        return False

    def __style_set(self, widget, _previous_style):
        style = widget.get_style_context()
        link_color = style.get_color(Gtk.StateFlags.LINK)
        self.link_tag.set_property('foreground-rgba', link_color)
        self.link_tag.set_property('underline', Pango.Underline.SINGLE)

    def do_set_property(self, prop, value):
        if prop.name == 'labellike':
            self.labellike = value
            if self.labellike:
                self.set_wrap_mode(Gtk.WrapMode.WORD)
                self.set_editable(False)
                self.set_cursor_visible(False)
                self.__style_set(self, None)

    def display_html(self, html):
        buf = self.get_buffer()
        eob = buf.get_end_iter()
        ## this works too if libxml2 is not available
        #parser = xml.sax.make_parser(['drv_libxml2'])
        parser = xml.sax.make_parser()
        # parser.setFeature(xml.sax.handler.feature_validation, True)
        parser.setContentHandler(HtmlHandler(self, eob))
        #parser.setEntityResolver(HtmlEntityResolver())
        # The parser expects XHTML
        html = html.replace('<br>', '<br/>').replace('</br>', '')
        # The word-break tag is not supported
        html = html.replace('<wbr>', '').replace('</wbr>', '')
        # &nbsp; is an important HTML typographic entity (e.g. in French) but
        # is not supported by the XML parser. So try to manually define it
        # along with some other commonly used entities.
        if not html.startswith('<!DOCTYPE'):
            html = '<!DOCTYPE body [ ' + \
                   '<!ENTITY copy "&#xa9;"> ' + \
                   '<!ENTITY hellip "&#x2026;"> ' + \
                   '<!ENTITY mdash "&#x2014;"> ' + \
                   '<!ENTITY nbsp "&#xa0;"> ' + \
                   '<!ENTITY reg "&#xae;"> ' + \
                   '<!ENTITY trade "&#x2122;"> ' + \
                   ']>' + html
        if not isinstance(html, type('')) and isinstance(html, type(u'')):
            # the xml parser has trouble with unicode sometimes
            html = html.encode('utf8')
        parser.parse(StringIO(html))

        if eob.starts_line():
            eob_1 = buf.get_end_iter()
            eob_1.backward_char()
            buf.delete(eob_1, eob)

GObject.type_register(HtmlTextView)

def glade_create(_str1, _str2, _int1, _int2):
    widget = HtmlTextView()
    return widget


if __name__ == '__main__':
    htmlview = HtmlTextView()
    def url_cb(view, url, type_):
        print("url-clicked", url, type_)
    htmlview.connect("url-clicked", url_cb)
    htmlview.display_html('<div><span style="color: red; text-decoration:underline">Hello</span><br/>\n'
                          '  <img src="http://images.slashdot.org/topics/topicsoftware.gif"/><br/>\n'
                          '  <span style="font-size: 500%; font-family: serif">World</span>\n'
                          '</div>\n')
    htmlview.display_html("<br/>")
    htmlview.display_html("""
      <p style='font-size:large'>
        <span style='font-style: italic'>O<span style='font-size:larger'>M</span>G</span>,
        I&apos;m <span style='color:green'>green</span>
        with <span style='font-weight: bold'>envy</span>!
      </p>
        """)
    htmlview.display_html("<br/>")
    htmlview.display_html("""
    <body xmlns='http://www.w3.org/1999/xhtml'>
      <p>As Emerson said in his essay <span style='font-style: italic; background-color:cyan'>Self-Reliance</span>:</p>
      <p style='margin-left: 5px; margin-right: 2%'>
        &quot;A foolish consistency is the hobgoblin of little minds.&quot;
      </p>
    </body>
        """)
    htmlview.display_html("<br/>")
    htmlview.display_html("""
    <body xmlns='http://www.w3.org/1999/xhtml'>
      <p style='text-align:center'>Hey, are you licensed to <a href='http://www.jabber.org/'>Jabber</a>?</p>
      <p style='text-align:right'><img src='http://www.jabber.org/images/psa-license.jpg'
              alt='A License to Jabber'
              height='261'
              width='537'/></p>
    </body>
        """)

    htmlview.display_html("""
    <body xmlns='http://www.w3.org/1999/xhtml'>
      <ul style='background-color:rgb(120,140,100)'>
       <li> One </li>
       <li> Two </li>
       <li> Three </li>
      </ul>
    </body>
        """)
    htmlview.display_html("""
    <body xmlns='http://www.w3.org/1999/xhtml'>
      <ol>
       <li> One </li>
       <li> Two </li>
       <li> Three </li>
      </ol>
    </body>
        """)

    htmlview.display_html("""
<p>
Can we add button to return in project root directory in filemanager ?
</p>
        """)

    htmlview.display_html('<body><span style="font-family: monospace">|&#xA0;&#xA0;&#xA0;|</span></body>')

    htmlview.show()
    sw = Gtk.ScrolledWindow()
    sw.set_property("hscrollbar-policy", Gtk.PolicyType.AUTOMATIC)
    sw.set_property("vscrollbar-policy", Gtk.PolicyType.AUTOMATIC)
    sw.set_property("border-width", 0)
    sw.add(htmlview)
    sw.show()
    frame = Gtk.Frame()
    frame.set_shadow_type(Gtk.ShadowType.IN)
    frame.show()
    frame.add(sw)
    w = Gtk.Window()
    w.add(frame)
    w.set_default_size(400, 300)
    w.show_all()
    w.connect("destroy", lambda w: Gtk.main_quit())
    Gtk.main()
