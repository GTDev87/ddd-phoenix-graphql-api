'use strict';

jest.unmock('../../web/static/js/components/Link');
import TestUtils from 'react-addons-test-utils';
import React from 'react';
import ReactDOM from 'react-dom';

import Link from '../../web/static/js/components/Link';

describe('the Link component', () => {
  describe('the search', () => {
    it('should display name of the link', () => {
      const node = {
        url: 'http://react.is.the.best.com',
        title: 'Why React?',
        createdAt: Date.now(),
      };

      const linkComponent = TestUtils.renderIntoDocument(
        <Link link={node} />
      );
      //
      // const label = TestUtils.findRenderedDOMComponentWithTag(linkComponent,'a');
      //
      // expect(lable.textContent).toEqual(link.title);
    });
  });
});
