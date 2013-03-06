$(function() {
  window.LayerEditor = Backbone.View.extend({
    events: {
      'click .expand': 'expand',
      'click': 'open'
    },

    initialize: function() {
      this.layers = this.options.layers;
      this.bus = this.options.bus;
      this.open = false;
      this.views = {};
      this.render();
    },

    expand: function(e) {
      if(e) {
        e.preventDefault();
      }
      this.render(this.layers.length);
    },

    render: function(howmany, order) {
      howmany = howmany || 3;
      var self = this;
      var el = this.$('.dropdown');
      el.find('li').each(function(i,el){$(el).remove()});
      _(this.layers.slice(0, howmany)).each(function(layer) {
        var v = self.views[layer.name];
        if (v) {
          delete self.views[layer.name];
        }
        v = new MapLayer({
          map_layer: layer,
          bus: self.bus
        });
        self.views[layer.name] = v;
        el.find('a.expand').before(v.render().el);
      });
      if(howmany === self.layers.length) {
        this.$('a.expand').hide();
      } else {
        this.$('a.expand').show();
      }
      el.sortable({
        revert: false,
        items: '.sortable',
        axis: 'y',
        cursor: 'pointer',
        stop:function(event,ui){
          $(ui.item).removeClass('moving');
          //
          //DONT CALL THIS FUNCTION ON beforeStop event, it will crash :D
          //
          self.sortLayers();
        },
        start:function(event,ui){
          $(ui.item).addClass('moving');
        }
      });
      this.updateLayerNumber();
      return this;
    },

    updateLayerNumber: function() {
      var t = 0;
      _(this.layers).each(function(a) {
        if(a.enabled) t++;
      });
    },

    sortLayers: function() {
      var order = [];
      this.$('li').each(function(i, el) {
        order.push($(el).attr('id'));
      });
      this.sort_by(order, true);
      this.bus.emit("map:reorder_layers", order);
    },

    open: function(e) {
      var _this = this;
      if(e) e.preventDefault();
      this.el.addClass('open');
      this.el.css("z-index","100");      
      this.open = true;
      $('body').click(function(e){
        _this.close(e);
      });
    },

    close: function(e) {
      if (this.el.has(e.target).length === 0) {
        // The click comes from outside the layer menu
        this.el.removeClass('open');
        this.el.css("z-index","10");
        this.open = false;
        $('body').unbind('click', this.close);
      }
    },

    sort_by: function(layers_order, silent) {
      this.layers.sort(function(a, b) {
        var ida = _(layers_order).indexOf(a.name);
        var idb = _(layers_order).indexOf(b.name);
        if(ida === -1) return 1;
        if(idb === -1) return -1;
        return ida - idb;
      });
      if(!silent) {
        this.open = true;
        this.hiding();
      }
    },

    hiding: function(e) {
      if(!this.open) return;
      // put first what are showing
      this.layers.sort(function(a, b) {
        if(a.enabled && !b.enabled) {
          return -1;
        } else if(!a.enabled && b.enabled) {
          return 1;
        }
        return 0;
      });
      layers = _(this.layers).pluck('name');
      //this.sort_by(layers);
      this.bus.emit("map:reorder_layers", layers);
      this.order = layers;
      this.render(3);
      this.close();
    }
  });
});
