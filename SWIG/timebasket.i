
/*
 Copyright (C) 2000, 2001, 2002 RiskMap srl

 This file is part of QuantLib, a free-software/open-source library
 for financial quantitative analysts and developers - http://quantlib.org/

 QuantLib is free software: you can redistribute it and/or modify it under the
 terms of the QuantLib license.  You should have received a copy of the
 license along with this program; if not, please email ferdinando@ametrano.net
 The license is also available online at http://quantlib.org/html/license.html

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
*/

// $Id$

#ifndef quantlib_timebasket_i
#define quantlib_timebasket_i

%include common.i
%include types.i
%include date.i

%{
using QuantLib::CashFlows::TimeBasket;
%}

class TimeBasket {
    #if defined (SWIGPYTHON) || defined(SWIGRUBY)
    %rename(__len__) size;
    #endif
  public:
    TimeBasket();
    TimeBasket(const std::vector<Date>&, const std::vector<double>&);
    Size size();
    TimeBasket rebin(const std::vector<Date>&) const;
    %extend {
        #if defined(SWIGPYTHON) || defined(SWIGRUBY)
        double __getitem__(const Date& d) {
            return (*self)[d];
        }
        void __setitem__(const Date& d, double value) {
            (*self)[d] = value;
        }
        #endif
        #if defined(SWIGPYTHON)
        PyObject* items() {
            PyObject* itemList = PyList_New(self->size());
            TimeBasket::iterator i;
            unsigned int j;
            for (i=self->begin(), j=0; i!=self->end(); ++i, ++j) {
                Date* d = new Date(i->first);
                PyObject* item = PyTuple_New(2);
                PyTuple_SetItem(item,0,
                                SWIG_NewPointerObj((void *) d,
                                                   $descriptor(Date *),1));
                PyTuple_SetItem(item,1,PyFloat_FromDouble(i->second));
                PyList_SetItem(itemList,j,item);
            }
            return itemList;
        }
        // Python 2.2 methods
        bool __contains__(const Date& d) {
            return self->hasDate(d);
        }
        PyObject* __iter__() {
            %#if PY_VERSION_HEX >= 0x02020000
            PyObject* keyList = PyList_New(self->size());
            TimeBasket::iterator i;
            unsigned int j;
            for (i=self->begin(), j=0; i!=self->end(); ++i, ++j) {
                Date* d = new Date(i->first);
                PyList_SetItem(keyList,j,
                               SWIG_NewPointerObj((void *) d,
                                                  $descriptor(Date *),1));
            }
            PyObject* iter = PyObject_GetIter(keyList);
            Py_DECREF(keyList);
            return iter;
            %#else
            throw std::runtime_error("Python 2.2 or later is needed"
                                     " for iterator support");
            %#endif
            }
        #endif
        #if defined(SWIGRUBY)
        void each() {
            TimeBasket::iterator i;
            for (i=self->begin(); i!=self->end(); ++i) {
                    Date* d = new Date(i->first);
                    VALUE entry = rb_ary_new2(2);
                    VALUE k = SWIG_NewPointerObj((void *) d,
                                                 $descriptor(Date *),1);
                    VALUE x = rb_float_new(i->second);
                    rb_ary_store(entry,0,k);
                    rb_ary_store(entry,1,x);
                    rb_yield(entry);
            }
        }
        #endif
    }
};


#endif