'use strict';

const e = React.createElement;

class CapabilityToggler extends React.Component {
  constructor(props) {
    super(props);
    // console.warn(props);
    this.state = {
      data: props.data,
      loading: false,
      hovered: false
    };
  }

  handleStart() {
    this.setState({
      loading: true
    })
  }

  handleComplete() {
    this.setState({
      loading: false
    })
  }

  handleSuccess(response) {
    // console.warn("SUCCESS!",response);
    this.setState({
      data: response
    });
  }

  handleFailure(response) {
    // console.warn("FAILED!",response);
  }
  enterState() {
    this.setState({
      hovered: true
    });
  }
  leaveState() {
    this.setState({
      hovered: false
    });
  }
  toggleState() {
    const toggleUrl = `/vehicles/${this.state.data.vehicle_config_id}/toggle_capability_state.json`;
    
    $.ajax({
      url: toggleUrl,
      dataType: 'json',
      type: 'get',
      beforeSend: () => this.handleStart(),
      success: (response) => this.handleSuccess(response),
      failed: (response) => this.handleFailure(response),
      complete: () => this.handleComplete(),
      data: this.state.data
    });
  }
  getConfigureLink() {
    let link_url;

    if (!this.state.data.id || this.state.data.state === 0) {
      return;
    }
    
    return e(
      'a',
      {
        className: "configure-link btn btn-configure",
        "data-behavior": "dialog",
        key: 'configure',
        href: `/vehicle_config_capabilities/${this.state.data.id}/edit`, 
        onMouseEnter: () => { 
          this.enterState()
        },
        onMouseLeave: () => {
          this.leaveState()
        }
      },
      "Configure"
    )
  }
  getIcon() {
    const iconClass = this.getIconClass();
    return e(
      'span',
      { 
        className: iconClass 
      }
    );
  }
  getLabel() {
    return e(
      'span',
      {
        className: "label-text"
      },
      this.state.data.value_type !== 'state' ? this.state.data.friendly_text : this.getIcon()
    )
  }
  getTypeLabel() {
    return e(
      'span',
      {
        className: "type-label"
      },
      this.state.data.value_type !== 'state' ? this.state.data.value_type : null
    )
  }
  getIconClass() {
    let iconClass;
    if (this.state.loading) {
      return "fa fa-spinner fa-spin"
    }
    switch (this.state.data.state) {
      case 0:
        return "fa fa-plus";
      case 1:
        return "fa fa-check";
      case 2:
        return "fa fa-times";
      default:
        return "fa fa-plus";
    }
  }
  getClasses() {
    if (this.state.data.state === 1) {
      return "btn btn-success";
    } else if (this.state.data.state === 2) {
      return "btn btn-danger";
    } else {
      return "btn btn-add btn-default";
    }
  }
  render() {
    const { data, loading } = this.state;
    let icon;

    if (loading) {
      icon = this.getIcon();
      return e(
        'a',
        { 
          href: "#", onClick: () => { this.toggleState() } 
        },
        icon
      );
    }

    icon = this.getIcon();

    var elems = [e(
        'a',
        {
          key: 'toggler',
          className: this.getClasses(), 
          href: "#", 
          onClick: () => { 
            this.toggleState() 
          }, 
          onMouseEnter: () => { 
            this.enterState()
          },
          onMouseLeave: () => {
            this.leaveState()
          }
        },
      this.getLabel(),
      this.getTypeLabel()
    )];

    if (this.state.hovered) {
      elems.push(this.getConfigureLink());
    }
    return elems;
  }
}

$(Trestle).on("init",function() {
  document.querySelectorAll('.vehicle-capability-control').forEach(domContainer => {
    // Read the comment ID from a data-* attribute.
    const defaultState = JSON.parse(domContainer.dataset.defaultState);
    ReactDOM.render(
      e(CapabilityToggler, {
        data: defaultState || {
          "id": null,
          "state":0,
          "vehicle_config_id":586,
          "vehicle_capability_id":32,
          "vehicle_config_type_id":1,
          "kph":null,
          "timeout":null,
          "confirmed":null,
          "notes":null,
          "created_at": null,
          "updated_at":null,
          "confirmed_by_id":null,
          "string_value":null}
      }),
      domContainer
    );
  });
});