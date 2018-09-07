'use strict';

class FollowButton extends React.Component {
  constructor(props) {
    super(props);
    
    this.state = {
      data: props.data,
      loading: false,
      hovered: false,
      error: null
    };
  }
  handleEnter() {
    this.setState({
      hovered: true
    })
  }
  handleLeave() {
    this.setState({
      hovered: false
    })
  }

  handleStart() {
    this.setState({
      loading: true
    })
  }

  handleComplete() {
    this.setState({
      loading: false
    });
  }

  handleSuccess(response) {
    console.warn("SUCCESS!",response);
    this.setState({
      data: response
    });
  }

  handleFailure(response) {
    // console.warn("FAILED!",data);
    // alert("failure");
    this.setState({
      error: response.responseJSON.error
    })

  }

  getPopover(message) {
    return e(
      "div",
      {
        className: "pop-error"
      },
      message
    )
  }

  getClasses() {
    let classes = []; 
    classes.push("btn");
    classes.push("btn-default");
    classes.push("btn-follow");
    if (this.isFollowing()) {
      classes.push('following');
    }
    return classes.join(" ");
  }
  isFollowing() {
    return this.state.data.following.includes(this.state.data.id);
  }
  toggleState() {
    const toggleUrl = `/vehicles/${this.state.data.id}/follow.json`;
    
    $.ajax({
      url: toggleUrl,
      dataType: 'json',
      type: 'get',
      beforeSend: () => this.handleStart(),
      success: (response) => this.handleSuccess(response),
      error: (response) => this.handleFailure(response),
      complete: () => this.handleComplete(),
      data: this.state.data
    });
  }
  getIcon(icon) {
    return e(
      'span',
      {
        className: "fa fa-" + icon
      }
    ) 
  }
  getLabel() {
    if (this.state.loading) {
      return this.getIcon('spinner fa-spin');
    } else {
      if (this.isFollowing()) {
        return this.getIcon('heart');
      } else {
        return this.getIcon('heart-o');
      }
    }
  }
  render() {
    const { data, loading, following } = this.state;
    let renders = [];
    
    const elem = e('button',
      {
        key: 'follow-btn',
        className: this.getClasses(),
        onClick: () => { 
          this.toggleState() 
        },
        onMouseEnter: () => { 
          this.handleEnter() 
        },
        onMouseLeave: () => { 
          this.handleLeave() 
        }
      },
      this.getLabel()
    );
    if (this.state.error) {
      renders.push(this.getPopover(this.state.error))
    }
    renders.push(elem);

    return renders
  }
}

$(Trestle).on("init",function() {
  document.querySelectorAll('.follow-button').forEach(domContainer => {
    // Read the comment ID from a data-* attribute.
    const defaultState = JSON.parse(domContainer.dataset.defaultState);
    ReactDOM.render(
      e(FollowButton, {
        data: defaultState || {
          "vehicle": null,
          "user": null
        }
      }),
      domContainer
    );
  });
});